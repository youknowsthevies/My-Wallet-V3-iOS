// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import EthereumKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class ERC20OnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - OnChainTransactionEngine

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    let requireSecondPassword: Bool

    // MARK: - Private Properties

    private let hotWalletAddressService: HotWalletAddressServiceAPI
    private let receiveAddressFactory: ExternalAssetAddressServiceAPI
    private let erc20Token: AssetModel
    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: EthereumKit.EthereumFeeServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI
    private let transactionsService: EthereumHistoricalTransactionServiceAPI

    /// The current transactionTarget receive address.
    private var receiveAddress: Single<ReceiveAddress> {
        switch transactionTarget {
        case let target as ReceiveAddress:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress
        case let target as HotWalletTransactionTarget:
            return .just(target.hotWalletAddress)
        default:
            fatalError(
                "Impossible State \(type(of: self)): transactionTarget is \(type(of: transactionTarget))"
            )
        }
    }

    /// The current transactionTarget address reference.
    /// If we are not sending directly to a HotWalletTransactionTarget, then this will emit 'nil'.
    private var addressReference: Single<ReceiveAddress?> {
        switch transactionTarget {
        case let target as HotWalletTransactionTarget:
            return .just(target.realAddress)
        default:
            return .just(nil)
        }
    }

    private var erc20CryptoAccount: ERC20CryptoAccount {
        sourceAccount as! ERC20CryptoAccount
    }

    // MARK: - Init

    init(
        erc20Token: AssetModel,
        requireSecondPassword: Bool,
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve(),
        feeService: EthereumKit.EthereumFeeServiceAPI = resolve(),
        hotWalletAddressService: HotWalletAddressServiceAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve(),
        transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
        transactionsService: EthereumHistoricalTransactionServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.currencyConversionService = currencyConversionService
        self.erc20Token = erc20Token
        self.ethereumTransactionDispatcher = ethereumTransactionDispatcher
        self.feeService = feeService
        self.hotWalletAddressService = hotWalletAddressService
        self.receiveAddressFactory = receiveAddressFactory
        self.requireSecondPassword = requireSecondPassword
        self.transactionBuildingService = transactionBuildingService
        self.transactionsService = transactionsService
        self.walletCurrencyService = walletCurrencyService

        feeCache = CachedValue(
            configuration: .onSubscription(
                schedulerIdentifier: "ERC20OnChainTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService.fees(cryptoCurrency: self.sourceCryptoCurrency)
        }
    }

    // MARK: - OnChainTransactionEngine

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceAccount is ERC20CryptoAccount)
        precondition(sourceCryptoCurrency.isERC20)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            walletCurrencyService
                .displayCurrency
                .asSingle(),
            availableBalance
        )

        .map { [erc20Token] fiatCurrency, availableBalance -> PendingTransaction in
            .init(
                amount: .zero(currency: .erc20(erc20Token)),
                available: availableBalance,
                feeAmount: .zero(currency: .coin(.ethereum)),
                feeForFullAvailable: .zero(currency: .coin(.ethereum)),
                feeSelection: .init(
                    selectedLevel: .regular,
                    availableLevels: [.regular, .priority],
                    asset: .crypto(.coin(.ethereum))
                ),
                selectedFiatCurrency: fiatCurrency
            )
        }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                makeFeeSelectionOption(pendingTransaction: pendingTransaction)
            )
            .map { fiatAmountAndFees, feeSelectionOption ->
                (
                    amountInFiat: MoneyValue,
                    feesInFiat: MoneyValue,
                    feeSelectionOption: TransactionConfirmation.Model.FeeSelection
                ) in
                let (amountInFiat, feesInFiat) = fiatAmountAndFees
                return (amountInFiat.moneyValue, feesInFiat.moneyValue, feeSelectionOption)
            }
            .map(weak: self) { (self, payload) -> [TransactionConfirmation] in
                [
                    .sendDestinationValue(.init(value: pendingTransaction.amount)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.transactionTarget.label)),
                    .feeSelection(payload.feeSelectionOption),
                    .feedTotal(
                        .init(
                            amount: pendingTransaction.amount,
                            amountInFiat: payload.amountInFiat,
                            fee: pendingTransaction.feeAmount,
                            feeInFiat: payload.feesInFiat
                        )
                    )
                ]
            }
            .map { pendingTransaction.update(confirmations: $0) }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        guard crypto.currencyType == .erc20(erc20Token) else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        return Single.zip(
            sourceAccount.actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel, fetch: true)
        )
        .map { values -> PendingTransaction in
            let (actionableBalance, fee) = values
            return pendingTransaction.update(
                amount: amount,
                available: actionableBalance,
                fee: fee.moneyValue,
                feeForFullAvailable: fee.moneyValue
            )
        }
    }

    func doOptionUpdateRequest(
        pendingTransaction: PendingTransaction,
        newConfirmation: TransactionConfirmation
    ) -> Single<PendingTransaction> {
        switch newConfirmation {
        case .feeSelection(let value) where value.selectedLevel != pendingTransaction.feeLevel:
            return updateFeeSelection(
                pendingTransaction: pendingTransaction,
                newFeeLevel: value.selectedLevel,
                customFeeAmount: nil
            )
        default:
            return defaultDoOptionUpdateRequest(
                pendingTransaction: pendingTransaction,
                newConfirmation: newConfirmation
            )
        }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .andThen(validateNoPendingTransaction())
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        Single
            .zip(
                feeCache.valueSingle,
                destinationAddresses
            )
            .flatMap { [erc20CryptoAccount, erc20Token, transactionBuildingService] fee, destinationAddresses
                -> Single<EthereumTransactionCandidate> in
                erc20CryptoAccount.nonce
                    .flatMap { nonce in
                        transactionBuildingService.buildTransaction(
                            amount: pendingTransaction.amount,
                            to: destinationAddresses.destination,
                            addressReference: destinationAddresses.referenceAddress,
                            feeLevel: pendingTransaction.feeLevel,
                            fee: fee,
                            nonce: nonce,
                            contractAddress: erc20Token.contractAddress
                        ).publisher
                    }
                    .asSingle()
            }
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.ethereumTransactionDispatcher.send(
                    transaction: candidate,
                    secondPassword: secondPassword
                )
            }
            .map(\.transactionHash)
            .map { transactionHash -> TransactionResult in
                .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
            }
    }
}

extension ERC20OnChainTransactionEngine {
    /**
     Ethereum Destination addresses.

     - Returns: Single that emits a tuple with the destination address (`destination`) and the reference address
     (`referenceAddress`) for the current `transactionTarget`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private var destinationAddresses: Single<(destination: EthereumAddress, referenceAddress: EthereumAddress?)> {
        let receiveAddresses: Single<(destination: ReceiveAddress, referenceAddress: ReceiveAddress?)>
        switch transactionTarget {
        case let blockchainAccount as BlockchainAccount:
            receiveAddresses = createDestinationAddress(for: blockchainAccount)
        default:
            receiveAddresses = Single.zip(receiveAddress, addressReference)
                .map { (to: $0.0, reference: $0.1) }
        }

        return receiveAddresses
            .map { addresses -> (destination: EthereumAddress, referenceAddress: EthereumAddress?) in
                let destination = try EthereumAddress(string: addresses.destination.address)
                guard let referenceAddress = addresses.referenceAddress else {
                    return (destination, nil)
                }
                return (destination, try EthereumAddress(string: referenceAddress.address))
            }
    }

    /**
     Hot Wallet Receive Address.

     - Returns: Single that emits the hot wallet receive address for the given `product` and for the current `sourceCryptoCurrency`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private func hotWalletReceiveAddress(for product: HotWalletProduct) -> Single<CryptoReceiveAddress?> {
        hotWalletAddressService
            .hotWalletAddress(for: sourceCryptoCurrency, product: product)
            .asSingle()
            .flatMap { [sourceCryptoCurrency, receiveAddressFactory] hotWalletAddress -> Single<CryptoReceiveAddress?> in
                guard let hotWalletAddress = hotWalletAddress else {
                    return .just(nil)
                }
                return receiveAddressFactory.makeExternalAssetAddress(
                    asset: sourceCryptoCurrency,
                    address: hotWalletAddress,
                    label: hotWalletAddress,
                    onTxCompleted: { _ in .empty() }
                )
                .single
                .optional()
            }
    }

    /**
     Destination addresses for a BlockchainAccount.
     If we are sending to a Custodial Account (Trading, Exchange, Interest), we must generate the 'addressReference' ourselves.

     - Returns: Single that emits a tuple with the destination address (`destination`) and the reference address
     (`referenceAddress`) for the given `BlockchainAccount`.

     When sending a transaction to one of Blockchain's custodial products, we check if a hot wallet address for that product
     is available. If that is not available, reference address is null and the transaction happens as it normally would. If it is available,
     we will send the fund directly to the hot wallet address, and pass along the original address (real address) as the
     reference address, that will be added to the transaction data field or as a the third parameter of the overloaded transfer method.
     You can check how this works and the reasons for its implementation here:
     https://www.notion.so/blockchaincom/Up-to-75-cheaper-EVM-wallet-private-key-to-custody-transfers-9675695a02ec49b893af1095ead6cc07
     */
    private func createDestinationAddress(
        for blockchainAccount: BlockchainAccount
    ) -> Single<(destination: ReceiveAddress, referenceAddress: ReceiveAddress?)> {
        let product: HotWalletProduct
        switch blockchainAccount {
        case is CryptoTradingAccount:
            product = .trading
        case is InterestAccount:
            product = .rewards
        case is ExchangeAccount:
            product = .exchange
        default:
            return Single.zip(receiveAddress, addressReference)
                .map { receiveAddress, addressReference in
                    (destination: receiveAddress, referenceAddress: addressReference)
                }
        }
        return Single
            .zip(
                blockchainAccount.receiveAddress,
                hotWalletReceiveAddress(for: product)
            )
            .map { receiveAddress, hotWalletAddress in
                guard let hotWalletAddress = hotWalletAddress else {
                    return (destination: receiveAddress, referenceAddress: nil)
                }
                return (destination: hotWalletAddress, referenceAddress: receiveAddress)
            }
    }

    private func validateNoPendingTransaction() -> Completable {
        transactionsService
            .isWaitingOnTransaction
            .map { isWaitingOnTransaction -> Void in
                guard isWaitingOnTransaction == false else {
                    throw TransactionValidationFailure(state: .transactionInFlight)
                }
            }
            .asCompletable()
    }

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable { [erc20Token] in
            guard try pendingTransaction.amount > .zero(currency: .erc20(erc20Token)) else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minSpendable))
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        guard sourceAccount != nil else {
            fatalError("sourceAccount should never be nil when this is called")
        }
        return sourceAccount
            .actionableBalance
            .map { [sourceAccount, transactionTarget] actionableBalance -> Void in
                guard try pendingTransaction.amount <= actionableBalance else {
                    throw TransactionValidationFailure(
                        state: .insufficientFunds(
                            actionableBalance,
                            pendingTransaction.amount,
                            sourceAccount!.currencyType,
                            transactionTarget!.currencyType
                        )
                    )
                }
            }
            .asCompletable()
    }

    private func validateSufficientGas(pendingTransaction: PendingTransaction) -> Completable {
        Single
            .zip(
                ethereumAccountBalance,
                absoluteFee(with: pendingTransaction.feeLevel)
            )
            .map { balance, absoluteFee -> Void in
                guard try absoluteFee <= balance else {
                    throw TransactionValidationFailure(
                        state: .belowFees(absoluteFee.moneyValue, balance.moneyValue)
                    )
                }
            }
            .asCompletable()
    }

    private func makeFeeSelectionOption(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionConfirmation.Model.FeeSelection> {
        getFeeState(pendingTransaction: pendingTransaction)
            .map { feeState -> TransactionConfirmation.Model.FeeSelection in
                TransactionConfirmation.Model.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
    }

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            ethereumExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: .erc20(erc20Token))),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: .erc20(erc20Token)))
        )
        .map { sourceExchange, ethereumExchange, amount, feeAmount -> (FiatValue, FiatValue) in
            let erc20Quote = sourceExchange.quote.fiatValue!
            let ethereumQuote = ethereumExchange.quote.fiatValue!
            let fiatAmount = amount.convert(using: erc20Quote)
            let fiatFees = feeAmount.convert(using: ethereumQuote)
            return (fiatAmount, fiatFees)
        }
    }

    private func absoluteFee(with feeLevel: FeeLevel, fetch: Bool = false) -> Single<CryptoValue> {
        feeCache.valueSingle
            .map { fees -> CryptoValue in
                fees.absoluteFee(with: feeLevel.ethereumFeeLevel, isContract: true)
            }
    }

    private var ethereumAccountBalance: Single<CryptoValue> {
        erc20CryptoAccount.ethereumBalance
            .asSingle()
    }

    /// Streams `MoneyValuePair` for the exchange rate of the source ERC20 Asset in the current fiat currency.
    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
            .asSingle()
    }

    /// Streams `MoneyValuePair` for the exchange rate of Ethereum in the current fiat currency.
    private var ethereumExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [currencyConversionService] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: .crypto(.coin(.ethereum)), to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: .crypto(.coin(.ethereum))), quote: $0) }
            }
            .asSingle()
    }
}

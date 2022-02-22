// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class EthereumOnChainTransactionEngine: OnChainTransactionEngine {

    // MARK: - OnChainTransactionEngine

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI

    var askForRefreshConfirmation: AskForRefreshConfirmation!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    let requireSecondPassword: Bool
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

    // MARK: - Private Properties

    private let hotWalletAddressService: HotWalletAddressServiceAPI
    private let receiveAddressFactory: ExternalAssetAddressServiceAPI
    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: EthereumFeeServiceAPI
    private let ethereumAccountService: EthereumAccountServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let pendingTransactionRepository: PendingTransactionRepositoryAPI
    private let ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI

    private var ethereumCryptoAccount: EthereumCryptoAccount {
        sourceAccount as! EthereumCryptoAccount
    }

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

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        ethereumAccountService: EthereumAccountServiceAPI = resolve(),
        hotWalletAddressService: HotWalletAddressServiceAPI = resolve(),
        receiveAddressFactory: ExternalAssetAddressServiceAPI = resolve(),
        pendingTransactionRepository: PendingTransactionRepositoryAPI = resolve(),
        transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.feeService = feeService
        self.requireSecondPassword = requireSecondPassword
        self.ethereumAccountService = ethereumAccountService
        self.transactionBuildingService = transactionBuildingService
        self.pendingTransactionRepository = pendingTransactionRepository
        self.ethereumTransactionDispatcher = ethereumTransactionDispatcher
        self.hotWalletAddressService = hotWalletAddressService
        self.receiveAddressFactory = receiveAddressFactory
        feeCache = CachedValue(
            configuration: .periodic(
                seconds: 90,
                schedulerIdentifier: "EthereumOnChainTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService
                .fees(cryptoCurrency: self.sourceCryptoCurrency)
                .asSingle()
        }
    }

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceAccount is EthereumCryptoAccount)
        precondition(sourceCryptoCurrency == .ethereum)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            walletCurrencyService
                .displayCurrency
                .asSingle(),
            availableBalance
        )
        .map { [predefinedAmount] fiatCurrency, availableBalance -> PendingTransaction in
            let amount: MoneyValue
            if let predefinedAmount = predefinedAmount,
               predefinedAmount.currency == .ethereum
            {
                amount = predefinedAmount.moneyValue
            } else {
                amount = .zero(currency: .ethereum)
            }
            return PendingTransaction(
                amount: amount,
                available: availableBalance,
                feeAmount: .zero(currency: .ethereum),
                feeForFullAvailable: .zero(currency: .ethereum),
                feeSelection: .init(
                    selectedLevel: .regular,
                    availableLevels: [.regular, .priority],
                    asset: .crypto(.ethereum)
                ),
                selectedFiatCurrency: fiatCurrency
            )
        }
    }

    func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                getFeeState(pendingTransaction: pendingTransaction)
            )
            .map(weak: self) { (self, payload) -> PendingTransaction in
                let ((amount, fees), feeState) = payload
                return self.doBuildConfirmations(
                    pendingTransaction: pendingTransaction,
                    amountInFiat: amount.moneyValue,
                    feesInFiat: fees.moneyValue,
                    feeState: feeState
                )
            }
    }

    private func doBuildConfirmations(
        pendingTransaction: PendingTransaction,
        amountInFiat: MoneyValue,
        feesInFiat: MoneyValue,
        feeState: FeeState
    ) -> PendingTransaction {
        let sendDestinationValue = TransactionConfirmation.Model.SendDestinationValue(
            value: pendingTransaction.amount
        )
        let source = TransactionConfirmation.Model.Source(
            value: sourceAccount.label
        )
        let destination = TransactionConfirmation.Model.Destination(
            value: transactionTarget.label
        )
        let feeSelection = TransactionConfirmation.Model.FeeSelection(
            feeState: feeState,
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
        let feedTotal = TransactionConfirmation.Model.FeedTotal(
            amount: pendingTransaction.amount,
            amountInFiat: amountInFiat,
            fee: pendingTransaction.feeAmount,
            feeInFiat: feesInFiat
        )
        return pendingTransaction.update(
            confirmations: [
                .sendDestinationValue(sendDestinationValue),
                .source(source),
                .destination(destination),
                .feeSelection(feeSelection),
                .feedTotal(feedTotal)
            ]
        )
    }

    func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("Not a `CryptoValue`")
        }
        guard crypto.currencyType == .ethereum else {
            preconditionFailure("Not an ethereum value")
        }
        return Single.zip(
            sourceAccount.actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel)
        )
        .map { values -> PendingTransaction in
            let (actionableBalance, fee) = values
            let available = try actionableBalance - fee.moneyValue
            let zero: MoneyValue = .zero(currency: actionableBalance.currency)
            let max: MoneyValue = try .max(available, zero)
            return pendingTransaction.update(
                amount: amount,
                available: max,
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

    func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        sourceAccount.actionableBalance
            .flatMap(weak: self) { (self, actionableBalance) -> Single<PendingTransaction> in
                self.validateSufficientFunds(
                    pendingTransaction: pendingTransaction,
                    actionableBalance: actionableBalance
                )
                .andThen(self.validateNoPendingTransaction())
                .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
            }
    }

    func execute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        guard pendingTransaction.amount.currency == .crypto(.ethereum) else {
            fatalError("Not an ethereum value.")
        }

        return Single
            .zip(
                feeCache.valueSingle,
                destinationAddresses
            )
            .flatMap { [ethereumCryptoAccount, transactionBuildingService] fee, destinationAddresses -> Single<EthereumTransactionCandidate> in
                ethereumCryptoAccount.nonce
                    .flatMap { nonce in
                        transactionBuildingService.buildTransaction(
                            amount: pendingTransaction.amount,
                            to: destinationAddresses.destination,
                            addressReference: destinationAddresses.referenceAddress,
                            feeLevel: pendingTransaction.feeLevel,
                            fee: fee,
                            nonce: nonce,
                            chainID: ethereumCryptoAccount.network.chainID,
                            contractAddress: nil
                        ).publisher
                    }
                    .asSingle()
            }
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.ethereumTransactionDispatcher
                    .send(transaction: candidate, secondPassword: secondPassword)
            }
            .map(\.transactionHash)
            .map { transactionHash -> TransactionResult in
                .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
            }
    }

    func doRefreshConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }
}

extension EthereumOnChainTransactionEngine {
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
        pendingTransactionRepository
            .isWaitingOnTransaction(
                network: ethereumCryptoAccount.network,
                address: ethereumCryptoAccount.publicKey
            )
            .replaceError(with: true)
            .flatMap { isWaitingOnTransaction in
                isWaitingOnTransaction
                    ? AnyPublisher.failure(TransactionValidationFailure(state: .transactionInFlight))
                    : AnyPublisher.just(())
            }
            .asCompletable()
    }

    private func validateSufficientFunds(
        pendingTransaction: PendingTransaction,
        actionableBalance: MoneyValue
    ) -> Completable {
        absoluteFee(with: pendingTransaction.feeLevel)
            .map { [sourceAccount, transactionTarget] fee -> Void in
                guard try pendingTransaction.amount >= pendingTransaction.minSpendable else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minLimit))
                }
                guard try actionableBalance > fee.moneyValue else {
                    throw TransactionValidationFailure(state: .belowFees(fee.moneyValue, actionableBalance))
                }
                guard try (fee.moneyValue + pendingTransaction.amount) <= actionableBalance else {
                    throw TransactionValidationFailure(
                        state: .insufficientFunds(
                            pendingTransaction.available,
                            pendingTransaction.amount,
                            sourceAccount!.currencyType,
                            transactionTarget!.currencyType
                        )
                    )
                }
            }
            .asCompletable()
    }

    private func absoluteFee(with feeLevel: FeeLevel) -> Single<CryptoValue> {
        let network = ethereumCryptoAccount.network
        let isContract = receiveAddress
            .flatMap { [ethereumAccountService] receiveAddress in
                ethereumAccountService
                    .isContract(
                        network: network,
                        address: receiveAddress.address
                    )
                    .asSingle()
            }

        return Single
            .zip(feeCache.valueSingle, isContract)
            .map { (fees: EthereumTransactionFee, isContract: Bool) -> CryptoValue in
                let level: EthereumTransactionFee.FeeLevel
                switch feeLevel {
                case .none:
                    fatalError("On chain ETH transactions should never have a 0 fee")
                case .custom:
                    fatalError("Not supported")
                case .priority:
                    level = .priority
                case .regular:
                    level = .regular
                }
                return fees.absoluteFee(with: level, isContract: isContract)
            }
    }

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: .ethereum)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: .ethereum))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convert(using: quote)
            let fiatFees = fees.convert(using: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [sourceAsset, currencyConversionService] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
            .asSingle()
    }
}

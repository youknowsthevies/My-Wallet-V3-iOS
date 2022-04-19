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

    private let ethereumOnChainEngineCompanion: EthereumOnChainEngineCompanionAPI
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

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        ethereumAccountService: EthereumAccountServiceAPI = resolve(),
        ethereumOnChainEngineCompanion: EthereumOnChainEngineCompanionAPI = resolve(),
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
        self.ethereumOnChainEngineCompanion = ethereumOnChainEngineCompanion
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
                amount = predefinedAmount
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
        .map { actionableBalance, fee -> PendingTransaction in
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
        let ethereumCryptoAccount = ethereumCryptoAccount
        let transactionBuildingService = transactionBuildingService
        let destinationAddresses = ethereumOnChainEngineCompanion
            .destinationAddresses(
                transactionTarget: transactionTarget,
                cryptoCurrency: sourceCryptoCurrency,
                receiveAddressFactory: receiveAddressFactory
            )
        let extraGasLimit = ethereumOnChainEngineCompanion
            .extraGasLimit(
                transactionTarget: transactionTarget,
                cryptoCurrency: sourceCryptoCurrency,
                receiveAddressFactory: receiveAddressFactory
            )
        return Single
            .zip(
                feeCache.valueSingle,
                destinationAddresses,
                receiveAddressIsContract,
                extraGasLimit
            )
            .flatMap { fee, destinationAddresses, isContract, extraGasLimit
                -> Single<EthereumTransactionCandidate> in
                ethereumCryptoAccount.nonce
                    .flatMap { nonce in
                        transactionBuildingService.buildTransaction(
                            amount: pendingTransaction.amount,
                            to: destinationAddresses.destination,
                            addressReference: destinationAddresses.referenceAddress,
                            gasPrice: fee.gasPrice(
                                feeLevel: pendingTransaction.feeLevel.ethereumFeeLevel
                            ),
                            gasLimit: fee.gasLimit(
                                extraGasLimit: extraGasLimit,
                                isContract: isContract
                            ),
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

    /// Returns Ethereum CryptoValue of the maximum fee that the user may pay.
    private func absoluteFee(with feeLevel: FeeLevel) -> Single<CryptoValue> {
        Single
            .zip(feeCache.valueSingle, receiveAddressIsContract)
            .flatMap(weak: self) { (self, values) -> Single<CryptoValue> in
                let (fees, isContract) = values
                return self.ethereumOnChainEngineCompanion
                    .absoluteFee(
                        feeLevel: feeLevel,
                        fees: fees,
                        transactionTarget: self.transactionTarget,
                        cryptoCurrency: self.sourceCryptoCurrency,
                        receiveAddressFactory: self.receiveAddressFactory,
                        isContract: isContract
                    )
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

    /// Returns true if the destination address is a contract.
    private var receiveAddressIsContract: Single<Bool> {
        let network = ethereumCryptoAccount.network
        return ethereumOnChainEngineCompanion
            .receiveAddress(transactionTarget: transactionTarget)
            .flatMap { [ethereumAccountService] receiveAddress in
                ethereumAccountService
                    .isContract(
                        network: network,
                        address: receiveAddress.address
                    )
                    .asSingle()
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

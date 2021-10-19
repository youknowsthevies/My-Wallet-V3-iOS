// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class NonCustodialSellTransactionEngine: SellTransactionEngine {
    let receiveAddressFactory: CryptoReceiveAddressFactoryService
    let fiatCurrencyService: FiatCurrencyServiceAPI
    let kycTiersService: KYCTiersServiceAPI
    let onChainEngine: OnChainTransactionEngine
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .fromUserKey
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderUpdateRepository: OrderUpdateRepositoryAPI
    let priceService: PriceServiceAPI
    let quotesEngine: SwapQuotesEngine
    let requireSecondPassword: Bool
    let tradeLimitsRepository: TransactionLimitsRepositoryAPI
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    init(
        quotesEngine: SwapQuotesEngine,
        requireSecondPassword: Bool,
        onChainEngine: OnChainTransactionEngine,
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve(),
        orderUpdateRepository: OrderUpdateRepositoryAPI = resolve(),
        tradeLimitsRepository: TransactionLimitsRepositoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        receiveAddressFactory: CryptoReceiveAddressFactoryService = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.requireSecondPassword = requireSecondPassword
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
        self.orderUpdateRepository = orderUpdateRepository
        self.tradeLimitsRepository = tradeLimitsRepository
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        self.priceService = priceService
        self.onChainEngine = onChainEngine
        self.receiveAddressFactory = receiveAddressFactory
    }

    func assertInputsValid() {
        precondition(sourceAccount is NonCustodialAccount)
        precondition(transactionTarget is FiatAccount)
    }

    private func startOnChainEngine(pricedQuote: PricedQuote) -> Completable {
        let value = receiveAddressFactory.makeExternalAssetAddress(
            asset: sourceAsset,
            address: pricedQuote.sampleDepositAddress,
            label: pricedQuote.sampleDepositAddress,
            onTxCompleted: { _ in .empty() }
        )
        switch value {
        case .failure(let error):
            return .just(event: .error(error))
        case .success(let receiveAddress):
            onChainEngine.start(
                sourceAccount: sourceAccount,
                transactionTarget: receiveAddress,
                askForRefreshConfirmation: { _ in .empty() }
            )
            return .just(event: .completed)
        }
    }

    private func defaultFeeLevel(pendingTransaction: PendingTransaction) -> FeeLevel {
        if pendingTransaction.feeSelection.availableLevels.contains(.priority) {
            return .priority
        }
        return pendingTransaction.feeSelection.selectedLevel
    }

    private func doValidateAmount(pendingTransaction: PendingTransaction) -> Completable {
        sourceAccount
            .actionableBalance
            .map(weak: self) { (self, balance) -> Void in
                guard try pendingTransaction.amount <= balance else {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
                guard let minimumLimit = pendingTransaction.minimumLimit else {
                    Logger.shared.error("Minimum Limit is nil: \(pendingTransaction)")
                    throw TransactionValidationFailure(state: .unknownError)
                }
                guard let maximumLimit = pendingTransaction.maximumLimit else {
                    Logger.shared.error("Maximum Limit is nil: \(pendingTransaction)")
                    throw TransactionValidationFailure(state: .unknownError)
                }
                guard try pendingTransaction.amount >= minimumLimit else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit)
                }
                guard try pendingTransaction.amount <= maximumLimit else {
                    throw self.validationFailureForTier(pendingTransaction: pendingTransaction)
                }
            }
            .asCompletable()
    }

    private func validationFailureForTier(pendingTransaction: PendingTransaction) -> TransactionValidationFailure {
        guard let userTiers = pendingTransaction.userTiers else {
            return TransactionValidationFailure(state: .unknownError)
        }
        if userTiers.isTier2Approved {
            return TransactionValidationFailure(state: .overGoldTierLimit)
        }
        return TransactionValidationFailure(state: .overSilverTierLimit)
    }

    func defaultValidateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doValidateAmount(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine.validateAmount(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                switch pendingTransaction.validationState {
                case .canExecute, .invalidAmount:
                    return self.defaultValidateAmount(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        quotesEngine
            .getRate(direction: orderDirection, pair: pair)
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, pricedQuote) -> Single<PendingTransaction> in
                self.startOnChainEngine(pricedQuote: pricedQuote)
                    .andThen(
                        Single.zip(
                            self.fiatCurrencyService.fiatCurrency,
                            self.onChainEngine.initializeTransaction()
                        )
                    )
                    .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                        let (fiatCurrency, pendingTransaction) = payload

                        let fallback = PendingTransaction(
                            amount: CryptoValue.zero(currency: self.sourceAsset).moneyValue,
                            available: FiatValue.zero(currency: self.targetAsset).moneyValue,
                            feeAmount: FiatValue.zero(currency: self.targetAsset).moneyValue,
                            feeForFullAvailable: CryptoValue.zero(currency: self.sourceAsset).moneyValue,
                            feeSelection: .empty(asset: self.sourceAsset),
                            selectedFiatCurrency: fiatCurrency
                        )
                        return self.updateLimits(
                            pendingTransaction: pendingTransaction,
                            pricedQuote: pricedQuote,
                            fiatCurrency: fiatCurrency
                        )
                        .map(weak: self) { (self, pendingTx) -> PendingTransaction in
                            pendingTx
                                .update(selectedFeeLevel: self.defaultFeeLevel(pendingTransaction: pendingTx))
                        }
                        .handlePendingOrdersError(initialValue: fallback)
                    }
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        onChainEngine
            .doValidateAll(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                switch pendingTransaction.validationState {
                case .canExecute, .invalidAmount:
                    return self.defaultDoValidateAll(pendingTransaction: pendingTransaction)
                default:
                    return .just(pendingTransaction)
                }
            }
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func defaultDoValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, sellOrder) -> Single<TransactionResult> in
                guard let depositAddress = sellOrder.depositAddress else {
                    throw PlatformKitError.illegalStateException(message: "Missing deposit address")
                }
                return self.receiveAddressFactory
                    .makeExternalAssetAddress(
                        asset: self.sourceAsset,
                        address: depositAddress,
                        label: depositAddress,
                        onTxCompleted: { _ in .empty() }
                    )
                    .single
                    .flatMap(weak: self) { (self, transactionTarget) -> Single<PendingTransaction> in
                        self.onChainEngine
                            .restart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction)
                    }
                    .flatMap(weak: self) { (self, pendingTransaction) -> Single<TransactionResult> in
                        self.onChainEngine
                            .execute(pendingTransaction: pendingTransaction, secondPassword: secondPassword)
                            .catchError(weak: self) { (self, error) -> Single<TransactionResult> in
                                self.orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: false)
                                    .asObservable()
                                    .ignoreElements()
                                    .catchError { _ in .empty() }
                                    .andThen(.error(error))
                            }
                            .flatMap(weak: self) { (self, result) -> Single<TransactionResult> in
                                self.orderUpdateRepository
                                    .updateOrder(identifier: sellOrder.identifier, success: true)
                                    .asObservable()
                                    .ignoreElements()
                                    .catchError { _ in .empty() }
                                    .andThen(.just(result))
                            }
                    }
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        onChainEngine.doUpdateFeeLevel(
            pendingTransaction: pendingTransaction,
            level: level,
            customFeeAmount: customFeeAmount
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateUpdateAmount(amount)
            .flatMap(weak: self) { (self, amount) -> Single<PendingTransaction> in
                self.onChainEngine
                    .update(amount: amount, pendingTransaction: pendingTransaction)
                    .do(onSuccess: { pendingTransaction in
                        self.quotesEngine.updateAmount(pendingTransaction.amount.amount)
                    })
                    .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
                        self.clearConfirmations(pendingTransaction: pendingTransaction)
                    }
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        quotesEngine.getRate(direction: orderDirection, pair: pair)
            .take(1)
            .asSingle()
            .map { [targetAsset] pricedQuote -> PendingTransaction in
                let resultValue = FiatValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let baseValue = MoneyValue.one(currency: pendingTransaction.amount.currency)
                let sellDestinationValue: MoneyValue = pendingTransaction.amount.convert(using: resultValue)
                let sellFiatFeeValue: MoneyValue = pendingTransaction.feeAmount.convert(using: resultValue)
                let sellTotalCryptoValue = (try? pendingTransaction.amount + pendingTransaction.feeAmount)!
                let sellTotalFiatValue = (try? sellDestinationValue + sellFiatFeeValue)!

                let confirmations: [TransactionConfirmation] = [
                    .sellSourceValue(.init(cryptoValue: pendingTransaction.amount.cryptoValue!)),
                    .sellDestinationValue(.init(fiatValue: sellDestinationValue.fiatValue!)),
                    .sellExchangeRateValue(.init(baseValue: baseValue, resultValue: resultValue)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .networkFee(.init(
                        primaryCurrencyFee: pendingTransaction.feeAmount,
                        secondaryCurrencyFee: sellFiatFeeValue,
                        feeType: .withdrawalFee
                    )),
                    .totalCost(.init(
                        primaryCurrencyFee: sellTotalCryptoValue,
                        secondaryCurrencyFee: sellTotalFiatValue
                    ))
                ]

                var pendingTransaction = pendingTransaction.update(confirmations: confirmations)
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                return pendingTransaction
            }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        target.onTxCompleted(transactionResult)
    }
}

extension PendingTransaction {

    fileprivate func calculateMinimumLimit(for quote: PricedQuote) throws -> MoneyValue {
        guard let minimumApiLimit = minimumApiLimit else {
            return MoneyValue.zero(currency: quote.networkFee.currencyType)
        }
        let destination = quote.networkFee.currencyType
        let source = amount.currencyType
        let price = MoneyValue(amount: quote.price, currency: destination)
        let totalFees = (try? quote.networkFee + quote.staticFee) ?? MoneyValue.zero(currency: destination)
        let convertedFees = totalFees.convert(usingInverse: price, currencyType: source)
        return (try? minimumApiLimit + convertedFees) ?? MoneyValue.zero(currency: destination)
    }
}

extension PendingTransaction {
    fileprivate var userTiers: KYC.UserTiers? {
        engineState[.userTiers] as? KYC.UserTiers
    }
}

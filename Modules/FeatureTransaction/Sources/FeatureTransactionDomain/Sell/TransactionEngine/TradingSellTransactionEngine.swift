// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingSellTransactionEngine: SellTransactionEngine {

    var requireSecondPassword: Bool = false
    let quotesEngine: SwapQuotesEngine
    let fiatCurrencyService: FiatCurrencyServiceAPI
    let kycTiersService: KYCTiersServiceAPI
    let transactionLimitsService: TransactionLimitsServiceAPI
    let orderQuoteRepository: OrderQuoteRepositoryAPI
    let orderCreationRepository: OrderCreationRepositoryAPI
    let orderDirection: OrderDirection = .internal

    init(
        quotesEngine: SwapQuotesEngine,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        orderQuoteRepository: OrderQuoteRepositoryAPI = resolve(),
        orderCreationRepository: OrderCreationRepositoryAPI = resolve()
    ) {
        self.quotesEngine = quotesEngine
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        self.transactionLimitsService = transactionLimitsService
        self.orderQuoteRepository = orderQuoteRepository
        self.orderCreationRepository = orderCreationRepository
    }

    // MARK: - Transaction Engine

    var askForRefreshConfirmation: (AskForRefreshConfirmation)!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    func assertInputsValid() {
        precondition(sourceAccount is TradingAccount)
        precondition(transactionTarget is FiatAccount)
    }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.currencyType
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single
            .zip(
                quotesEngine.getRate(direction: orderDirection, pair: pair).take(1).asSingle(),
                fiatCurrencyService.fiatCurrency,
                sourceAccount.actionableBalance
            )
            .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                let (pricedQuote, fiatCurrency, actionableBalance) = payload
                let pendingTransaction = PendingTransaction(
                    amount: .zero(currency: self.sourceAsset),
                    available: actionableBalance,
                    feeAmount: .zero(currency: self.sourceAsset),
                    feeForFullAvailable: .zero(currency: self.sourceAsset),
                    feeSelection: .empty(asset: self.sourceAsset),
                    selectedFiatCurrency: fiatCurrency
                )
                return self.updateLimits(
                    pendingTransaction: pendingTransaction,
                    pricedQuote: pricedQuote
                )
                .handlePendingOrdersError(initialValue: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { _ in
                TransactionResult.unHashed(amount: pendingTransaction.amount)
            }
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        return Single.just(pendingTransaction)
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(
            validateUpdateAmount(amount),
            sourceAccount.actionableBalance
        )
        .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
            pendingTransaction.update(amount: normalized, available: balance)
        }
        .do(onSuccess: { [weak self] transaction in
            self?.quotesEngine.updateAmount(transaction.amount.amount)
        })
        .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
            self.clearConfirmations(pendingTransaction: pendingTransaction)
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

                let confirmations: [TransactionConfirmation] = [
                    .sellSourceValue(.init(cryptoValue: pendingTransaction.amount.cryptoValue!)),
                    .sellDestinationValue(.init(fiatValue: sellDestinationValue.fiatValue!)),
                    .sellExchangeRateValue(.init(baseValue: baseValue, resultValue: resultValue)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label))
                ]

                var pendingTransaction = pendingTransaction.update(confirmations: confirmations)
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                return pendingTransaction
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
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
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
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

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
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

    fileprivate var userTiers: KYC.UserTiers? {
        engineState[.userTiers] as? KYC.UserTiers
    }
}

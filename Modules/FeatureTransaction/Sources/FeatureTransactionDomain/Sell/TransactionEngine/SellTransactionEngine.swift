// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import PlatformKit
import RxSwift

protocol SellTransactionEngine: TransactionEngine {

    var orderDirection: OrderDirection { get }
    var quotesEngine: SwapQuotesEngine { get }
    var kycTiersService: KYCTiersServiceAPI { get }
    var fiatCurrencyService: FiatCurrencyServiceAPI { get }
    var transactionLimitsService: TransactionLimitsServiceAPI { get }
    var orderQuoteRepository: OrderQuoteRepositoryAPI { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
}

extension SellTransactionEngine {

    var target: FiatAccount {
        transactionTarget as! FiatAccount
    }

    var sourceAsset: CryptoCurrency { sourceCryptoCurrency }
    var targetAsset: FiatCurrency { target.fiatCurrency }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currencyType,
            destinationCurrencyType: target.fiatCurrency.currencyType
        )
    }

    // MARK: - TransactionEngine

    func validateUpdateAmount(_ amount: MoneyValue) -> Single<MoneyValue> {
        guard canTransactFiat == amount.isFiat else {
            preconditionFailure("Engine.canTransactFiat \(canTransactFiat) but amount.isFiat: \(amount.isFiat)")
        }
        return .just(amount)
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        Single.zip(sourceExchangeRatePair, destinationExchangeRatePair)
            .map { source, destination -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: source,
                    destination: destination
                )
            }
            .asObservable()
    }

    var sourceExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .take(1)
            .asSingle()
    }

    private var destinationExchangeRatePair: Single<MoneyValuePair> {
        transactionExchangeRatePair
            .map(\.inverseExchangeRate)
            .take(1)
            .asSingle()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        quotesEngine
            .getRate(
                direction: orderDirection,
                pair: .init(
                    sourceCurrencyType: sourceAsset,
                    destinationCurrencyType: target.currencyType
                )
            )
            .map { [target] pricedQuote -> MoneyValue in
                MoneyValue(amount: pricedQuote.price, currency: target.currencyType)
            }
            .map { [sourceAsset] rate -> MoneyValuePair in
                MoneyValuePair(base: .one(currency: sourceAsset), exchangeRate: rate)
            }
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        pricedQuote: PricedQuote
    ) -> Single<PendingTransaction> {
        let kycTiersPublisher = kycTiersService
            .tiers
            .mapError(TransactionLimitsServiceError.other)
        let limitsPublisher = transactionLimitsService.fetchLimits(
            source: LimitsAccount(
                currency: sourceAsset.currencyType,
                accountType: orderDirection.isFromCustodial ? .custodial : .nonCustodial
            ),
            destination: LimitsAccount(
                currency: targetAsset.currencyType,
                accountType: orderDirection.isToCustodial ? .custodial : .nonCustodial
            ),
            product: .sell(orderDirection)
        )
        return kycTiersPublisher
            .zip(limitsPublisher)
            .asSingle()
            .map { tiers, limits -> (tiers: KYC.UserTiers, min: MoneyValue, max: MoneyValue) in
                (tiers, limits.minimum, limits.maximum)
            }
            .map { (tiers: KYC.UserTiers, min: MoneyValue, max: MoneyValue) -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.minimumApiLimit = min
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                pendingTransaction.maximumLimit = max
                pendingTransaction.engineState[.userTiers] = tiers
                return pendingTransaction
            }
    }

    func clearConfirmations(pendingTransaction oldValue: PendingTransaction) -> PendingTransaction {
        var pendingTransaction = oldValue
        let quoteSubscription = pendingTransaction.quoteSubscription
        quoteSubscription?.dispose()
        pendingTransaction.engineState[.quoteSubscription] = nil
        return pendingTransaction.update(confirmations: [])
    }

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SellOrder> {
        sourceAccount.receiveAddress
            .flatMap(weak: self) { (self, _) -> Single<SellOrder> in
                self.orderQuoteRepository.fetchQuote(
                    direction: self.orderDirection,
                    sourceCurrencyType: self.sourceAsset.currencyType,
                    destinationCurrencyType: self.target.currencyType
                )
                .asSingle()
                .flatMap(weak: self) { (self, quote) -> Single<SellOrder> in
                    self.orderCreationRepository.createOrder(
                        direction: self.orderDirection,
                        quoteIdentifier: quote.identifier,
                        volume: pendingTransaction.amount,
                        ccy: self.target.currencyType.code
                    )
                    .asSingle()
                }
            }
            .do(onDispose: { [weak self] in
                self?.disposeQuotesFetching(pendingTransaction: pendingTransaction)
            })
    }

    private func disposeQuotesFetching(pendingTransaction: PendingTransaction) {
        pendingTransaction.quoteSubscription?.dispose()
        quotesEngine.stop()
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

    fileprivate var quoteSubscription: Disposable? {
        engineState[.quoteSubscription] as? Disposable
    }
}

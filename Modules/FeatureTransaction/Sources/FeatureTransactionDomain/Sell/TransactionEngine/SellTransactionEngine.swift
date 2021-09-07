// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift

protocol SellTransactionEngine: TransactionEngine {
    var orderDirection: OrderDirection { get }

    var quotesEngine: SwapQuotesEngine { get }

    var kycTiersService: KYCTiersServiceAPI { get }
    var fiatCurrencyService: FiatCurrencyServiceAPI { get }
    var tradeLimitsRepository: TransactionLimitsRepositoryAPI { get }
    var orderQuoteRepository: OrderQuoteRepositoryAPI { get }
    var priceService: PriceServiceAPI { get }
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
            sourceCurrencyType: sourceAsset.currency,
            destinationCurrencyType: target.fiatCurrency.currency
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
        fiatCurrencyService
            .fiatCurrency
            .flatMap { [priceService, sourceAsset] fiatCurrency -> Single<MoneyValuePair> in
                priceService
                    .price(of: sourceAsset, in: fiatCurrency)
                    .map(\.moneyValue)
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
    }

    private var destinationExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap { [priceService, target] fiatCurrency in
                priceService
                    .price(of: target.currencyType, in: fiatCurrency)
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: target.currencyType), quote: $0) }
            }
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
                try MoneyValuePair(base: .one(currency: sourceAsset), exchangeRate: rate)
            }
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        pricedQuote: PricedQuote,
        fiatCurrency: FiatCurrency
    ) -> Single<PendingTransaction> {
        Single
            .zip(
                kycTiersService.tiers,
                tradeLimitsRepository.fetchTransactionLimits(
                    currency: fiatCurrency.currency,
                    networkFee: targetAsset.currency,
                    product: .sell(orderDirection)
                )
                .asObservable()
                .asSingle()
            )
            .map { tiers, limits -> (tiers: KYC.UserTiers, min: FiatValue, max: FiatValue) in
                (tiers, limits.minOrder, limits.maxOrder)
            }
            .flatMap { [sourceCryptoCurrency, priceService, sourceAsset] values -> Single<(KYC.UserTiers, MoneyValue, MoneyValue)> in
                let (tiers, min, max) = values
                return priceService
                    .price(
                        of: sourceAsset,
                        in: fiatCurrency
                    )
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { $0.fiatValue ?? .zero(currency: fiatCurrency) }
                    .map { quote -> (KYC.UserTiers, MoneyValue, MoneyValue) in
                        let minCrypto = min.convertToCryptoValue(
                            exchangeRate: quote,
                            cryptoCurrency: sourceCryptoCurrency
                        )
                        let maxCrypto = max.convertToCryptoValue(
                            exchangeRate: quote,
                            cryptoCurrency: sourceCryptoCurrency
                        )
                        return (tiers, .init(cryptoValue: minCrypto), .init(cryptoValue: maxCrypto))
                    }
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
            .flatMap {
                [
                    orderQuoteRepository,
                    orderCreationRepository,
                    orderDirection,
                    sourceAsset,
                    target
                ] _ -> Single<SellOrder> in
                orderQuoteRepository.fetchQuote(
                    direction: orderDirection,
                    sourceCurrencyType: sourceAsset.currency,
                    destinationCurrencyType: target.currencyType
                )
                .asObservable()
                .asSingle()
                .flatMap { [orderDirection, target] quote -> Single<SellOrder> in
                    orderCreationRepository.createOrder(
                        direction: orderDirection,
                        quoteIdentifier: quote.identifier,
                        volume: pendingTransaction.amount,
                        ccy: target.currencyType.code
                    )
                    .asObservable()
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
        let convertedFees = try totalFees.convert(usingInverse: price, currencyType: source)
        return (try? minimumApiLimit + convertedFees) ?? MoneyValue.zero(currency: destination)
    }
}

extension PendingTransaction {

    fileprivate var quoteSubscription: Disposable? {
        engineState[.quoteSubscription] as? Disposable
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkError
import ToolKit

public enum PriceServiceError: Error {
    case missingPrice
    case networkError(NetworkError)
}

public protocol PriceServiceAPI {

    /// Gets the money value pair of the given fiat value and crypto currency.
    ///
    /// - Parameters:
    ///  - fiatValue: The fiat value to use in the pair.
    ///  - cryptoCurrency: The crypto currency to use in the pair.
    ///  - usesFiatAsBase: Whether the base of the pair will be the fiat value or the crypto value.
    ///
    /// - Returns: A publisher that emits a `MoneyValuePair` on success, or a `PriceServiceError` on failure.
    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError>

    /// Gets the quoted price of the given base `Currency` in the given quote `Currency`, at the current time.
    ///
    /// - Parameters:
    ///  - base: The currency to get the price of.
    ///  - quote: The currency to get the price in.
    ///
    /// - Returns: A publisher that emits a `PriceQuoteAtTime` on success, or a `PriceServiceError` on failure.
    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError>

    /// Gets the quoted price of the given base `Currency` in the given quote `Currency`, at the given time.
    ///
    /// - Parameters:
    ///  - base: The currency to get the price of.
    ///  - quote: The currency to get the price in.
    ///  - time: The time to get the price at. A value of `nil` will default to the current time.
    ///
    /// - Returns: A publisher that emits a `PriceQuoteAtTime` on success, or a `PriceServiceError` on failure.
    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError>

    /// Gets the historical price series of the given `CryptoCurrency`-`FiatCurrency` pair, within the given price window.
    /// - Parameters:
    ///  - baseCurrency: The crypto currency to get the price series of.
    ///  - quoteCurrency: The fiat currency to get the price in.
    ///  - window: The price window to get the price in.
    ///
    /// - Returns: A publisher that emits a `HistoricalPriceSeries` on success, or a `PriceServiceError` on failure.
    func priceSeries(
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError>
}

final class PriceService: PriceServiceAPI {

    // MARK: - Private Properties

    private let repository: PriceRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    init(
        repository: PriceRepositoryAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.repository = repository
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError> {
        price(of: cryptoCurrency, in: fiatValue.currency)
            .map(\.moneyValue.fiatValue)
            .replaceNil(with: .zero(currency: fiatValue.currencyType))
            .map { price in
                MoneyValuePair(
                    fiatValue: fiatValue,
                    exchangeRate: price,
                    cryptoCurrency: cryptoCurrency,
                    usesFiatAsBase: usesFiatAsBase
                )
            }
            .eraseToAnyPublisher()
    }

    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        price(of: base, in: quote, at: .now)
    }

    private func allBases(for quote: Currency) -> [Currency] {
        enabledCurrenciesService.allEnabledCurrencies.filter { $0.code != quote.code }
    }

    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        let baseCode = base.code
        let quoteCode = quote.code

        guard baseCode != quoteCode else {
            // Base and Quote currencies are the same.
            return .just(
                PriceQuoteAtTime(
                    timestamp: time.date,
                    moneyValue: .one(currency: quote.currency)
                )
            )
        }
        let allBases: [Currency] = time.isSpecificDate
            ? [base] : allBases(for: quote)

        return repository
            .prices(of: allBases, in: quote, at: time)
            .mapError(PriceServiceError.networkError)
            .map { prices in
                // Get price of pair.
                prices["\(baseCode)-\(quoteCode)"]
            }
            .onNil(PriceServiceError.missingPrice)
            .eraseToAnyPublisher()
    }

    func priceSeries(
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError> {
        repository
            .priceSeries(of: baseCurrency, in: quoteCurrency, within: window)
            .mapError(PriceServiceError.networkError)
            .eraseToAnyPublisher()
    }
}

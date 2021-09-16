// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public protocol HistoricalFiatPriceProviding: AnyObject {

    /// Returns the service that matches the `CryptoCurrency`
    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI { get }
    func refresh(window: PriceWindow)
}

final class HistoricalFiatPriceProvider: HistoricalFiatPriceProviding {

    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        services[currency]!
    }

    // MARK: - Services

    private let services: [CryptoCurrency: HistoricalFiatPriceServiceAPI]

    // MARK: - Setup

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        exchangeProvider: ExchangeProviding = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        services = enabledCurrenciesService
            .allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: HistoricalFiatPriceServiceAPI]()) { result, cryptoCurrency in
                result[cryptoCurrency] = HistoricalFiatPriceService(
                    cryptoCurrency: cryptoCurrency,
                    pairExchangeService: exchangeProvider[cryptoCurrency],
                    fiatCurrencyService: fiatCurrencyService
                )
            }
    }

    func refresh(window: PriceWindow) {
        services.values.forEach { service in
            service.fetchTriggerRelay.accept(window)
        }
    }
}

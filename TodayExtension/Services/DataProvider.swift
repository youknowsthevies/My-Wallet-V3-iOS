// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class DataProvider {

    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding

    /// Exchange service for any asset
    let exchange: ExchangeProviding

    init(
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {

        // MARK: - ExchangeProvider

        let fiatExchangeServices = enabledCurrenciesService.allEnabledFiatCurrencies
            .reduce(into: [FiatCurrency: PairExchangeServiceAPI]()) { result, fiatCurrency in
                result[fiatCurrency] = PairExchangeService(
                    currency: fiatCurrency,
                    fiatCurrencyService: fiatCurrencyService
                )
            }
        let cryptoExchangeServices = enabledCurrenciesService.allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: PairExchangeServiceAPI]()) { result, cryptoCurrency in
                result[cryptoCurrency] = PairExchangeService(
                    currency: cryptoCurrency,
                    fiatCurrencyService: fiatCurrencyService
                )
            }

        let exchange = ExchangeProvider(
            fiats: fiatExchangeServices,
            cryptos: cryptoExchangeServices
        )
        self.exchange = exchange

        // MARK: - HistoricalFiatPriceProvider

        let cryptoFiatPriceServices = enabledCurrenciesService.allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: HistoricalFiatPriceServiceAPI]()) { result, cryptoCurrency in
                result[cryptoCurrency] = HistoricalFiatPriceService(
                    cryptoCurrency: cryptoCurrency,
                    exchangeAPI: exchange[cryptoCurrency],
                    fiatCurrencyService: fiatCurrencyService
                )
            }

        historicalPrices = HistoricalFiatPriceProvider(
            services: cryptoFiatPriceServices
        )
    }
}

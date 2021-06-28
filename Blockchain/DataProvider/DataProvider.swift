// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import InterestKit
import PlatformKit
import RxRelay
import RxSwift

protocol DataProviding: AnyObject {

    /// Returns all the exchange providers
    var exchange: ExchangeProviding { get }

    /// Returns all the historical asset price providers
    /// This service is wallet agnostic and provides the
    /// market prices over a given duration
    var historicalPrices: HistoricalFiatPriceProviding { get }
}

/// A container for common crypto services.
/// Rule of thumb: You shouldn't add any more code here.
final class DataProvider: DataProviding {

    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding

    /// Exchange service for any asset
    let exchange: ExchangeProviding

    init(
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
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

        self.historicalPrices = HistoricalFiatPriceProvider(
            services: cryptoFiatPriceServices
        )
    }
}

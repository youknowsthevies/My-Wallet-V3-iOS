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

    init(featureFetching: FeatureFetchingConfiguring = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
         enabledCurrencies: EnabledCurrenciesServiceAPI = resolve()) {

        var fiatExchangeServices: [FiatCurrency: PairExchangeServiceAPI] = [:]
        for fiatCurrency in enabledCurrencies.allEnabledFiatCurrencies {
            fiatExchangeServices[fiatCurrency] = PairExchangeService(
                currency: fiatCurrency,
                fiatCurrencyService: fiatCurrencyService
            )
        }

        var cryptoExchangeServices: [CryptoCurrency: PairExchangeServiceAPI] = [:]
        for cryptoCurrency in enabledCurrencies.allEnabledCryptoCurrencies {
            cryptoExchangeServices[cryptoCurrency] = PairExchangeService(
                currency: cryptoCurrency,
                fiatCurrencyService: fiatCurrencyService
            )
        }

        self.exchange = ExchangeProvider(
            fiats: fiatExchangeServices,
            cryptos: cryptoExchangeServices
        )

        let aaveHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .erc20(.aave),
            exchangeAPI: exchange[CryptoCurrency.erc20(.aave)],
            fiatCurrencyService: fiatCurrencyService
        )
        let algorandHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .algorand,
            exchangeAPI: exchange[CryptoCurrency.algorand],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoin,
            exchangeAPI: exchange[CryptoCurrency.bitcoin],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinCashHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoinCash,
            exchangeAPI: exchange[CryptoCurrency.bitcoinCash],
            fiatCurrencyService: fiatCurrencyService
        )
        let etherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            exchangeAPI: exchange[CryptoCurrency.ethereum],
            fiatCurrencyService: fiatCurrencyService
        )
        let paxHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .erc20(.pax),
            exchangeAPI: exchange[CryptoCurrency.erc20(.pax)],
            fiatCurrencyService: fiatCurrencyService
        )
        let polkadotHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .polkadot,
            exchangeAPI: exchange[CryptoCurrency.polkadot],
            fiatCurrencyService: fiatCurrencyService
        )
        let stellarHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            exchangeAPI: exchange[CryptoCurrency.stellar],
            fiatCurrencyService: fiatCurrencyService
        )
        let tetherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .erc20(.tether),
            exchangeAPI: exchange[CryptoCurrency.erc20(.tether)],
            fiatCurrencyService: fiatCurrencyService
        )
        let wDGLDHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .erc20(.wdgld),
            exchangeAPI: exchange[CryptoCurrency.erc20(.wdgld)],
            fiatCurrencyService: fiatCurrencyService
        )
        let yearnFinanceHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .erc20(.yearnFinance),
            exchangeAPI: exchange[CryptoCurrency.erc20(.yearnFinance)],
            fiatCurrencyService: fiatCurrencyService
        )

        self.historicalPrices = HistoricalFiatPriceProvider(
            aave: aaveHistoricalFiatService,
            algorand: algorandHistoricalFiatService,
            bitcoin: bitcoinHistoricalFiatService,
            bitcoinCash: bitcoinCashHistoricalFiatService,
            ether: etherHistoricalFiatService,
            pax: paxHistoricalFiatService,
            polkadot: polkadotHistoricalFiatService,
            stellar: stellarHistoricalFiatService,
            tether: tetherHistoricalFiatService,
            wDGLD: wDGLDHistoricalFiatService,
            yearnFinance: yearnFinanceHistoricalFiatService
        )
    }
}

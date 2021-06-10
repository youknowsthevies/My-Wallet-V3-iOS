// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AlgorandKit
import BitcoinCashKit
import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import PlatformKit
import PolkadotKit
import StellarKit

extension DependencyContainer {

    public static var activityKit = module {

        factory { TransactionDetailService() as TransactionDetailServiceAPI }

        factory { ActivityServiceContainer() as ActivityServiceContaining }

        // MARK: Public

        factory { () -> AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> in
            let ethereumActivityFetcher: EthereumActivityItemEventDetailsFetcher = DIKit.resolve()
            return AnyActivityItemEventDetailsFetcher(api: ethereumActivityFetcher)
        }

        factory { () -> AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> in
            let stellarActivityFetcher: StellarActivityItemEventDetailsFetcher = DIKit.resolve()
            return AnyActivityItemEventDetailsFetcher(api: stellarActivityFetcher)
        }

        factory { () -> AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> in
            let bitcoinActivityFetcher: BitcoinActivityItemEventDetailsFetcher = DIKit.resolve()
            return AnyActivityItemEventDetailsFetcher(api: bitcoinActivityFetcher)
        }

        factory { () -> AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> in
            let bitcoinCashActivityFetcher: BitcoinCashActivityItemEventDetailsFetcher = DIKit.resolve()
            return AnyActivityItemEventDetailsFetcher(api: bitcoinCashActivityFetcher)
        }

        // MARK: Private

        factory { () -> ActivityProviding in

            let euroEventService = FiatEventService(fiat: DIKit.resolve(tag: FiatCurrency.EUR))
            let gbpEventService = FiatEventService(fiat: DIKit.resolve(tag: FiatCurrency.GBP))
            let usdEventService = FiatEventService(fiat: DIKit.resolve(tag: FiatCurrency.USD))
            let enabledCurrenciesService: EnabledCurrenciesServiceAPI = DIKit.resolve()
            let cryptoCurrencies = enabledCurrenciesService.allEnabledCryptoCurrencies

            let cryptos = cryptoCurrencies
                .reduce(into: [CryptoCurrency: CryptoItemEventServiceAPI]()) { (result, cryptoCurrency) in
                    let component: CryptoItemEventServiceAPI = DIKit.resolve(tag: cryptoCurrency)
                    result[cryptoCurrency] = component
                }

            return ActivityProvider(
                fiats: [
                    FiatCurrency.EUR: euroEventService,
                    FiatCurrency.GBP: gbpEventService,
                    FiatCurrency.USD: usdEventService
                ],
                cryptos: cryptos
            )
        }

        factory { EmptyTransactionalActivityItemEventService() }

        factory { EmptySwapActivityItemEventService() }

        factory(tag: CryptoCurrency.erc20(.aave)) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.erc20(cryptoCurrency: .erc20(.aave))
        }

        factory(tag: CryptoCurrency.algorand) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.algorand()
        }

        factory(tag: CryptoCurrency.polkadot) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.polkadot()
        }

        factory(tag: CryptoCurrency.bitcoin) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.bitcoin()
        }

        factory(tag: CryptoCurrency.bitcoinCash) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.bitcoinCash()
        }

        factory(tag: CryptoCurrency.erc20(.tether)) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.erc20(cryptoCurrency: .erc20(.tether))
        }

        factory(tag: CryptoCurrency.erc20(.pax)) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.erc20(cryptoCurrency: .erc20(.pax))
        }

        factory(tag: CryptoCurrency.ethereum) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.ethereum()
        }

        factory(tag: CryptoCurrency.stellar) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.stellar()
        }

        factory(tag: CryptoCurrency.erc20(.wdgld)) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.erc20(cryptoCurrency: .erc20(.wdgld))
        }

        factory(tag: CryptoCurrency.erc20(.yearnFinance)) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.erc20(cryptoCurrency: .erc20(.yearnFinance))
        }
    }
}

extension CryptoEventService {
    fileprivate static func algorand() -> CryptoItemEventServiceAPI {
        custodial(currency: .algorand)
    }

    fileprivate static func bitcoin(eventsService: BitcoinTransactionalActivityItemEventsService = resolve()) -> CryptoItemEventServiceAPI {
        custodialNonCustodial(currency: .bitcoin, eventsService: eventsService)
    }

    fileprivate static func bitcoinCash(eventsService: BitcoinCashTransactionalActivityItemEventsService = resolve()) -> CryptoItemEventServiceAPI {
        custodialNonCustodial(currency: .bitcoinCash, eventsService: eventsService)
    }

    fileprivate static func ethereum(eventsService: EthereumTransactionalActivityItemEventsService = resolve()) -> CryptoItemEventServiceAPI {
        custodialNonCustodial(currency: .ethereum, eventsService: eventsService)
    }

    fileprivate static func polkadot() -> CryptoItemEventServiceAPI {
        custodial(currency: .polkadot)
    }

    fileprivate static func stellar(eventsService: StellarTransactionalActivityItemEventsService = resolve()) -> CryptoItemEventServiceAPI {
        custodialNonCustodial(currency: .stellar, eventsService: eventsService)
    }

    /// Returns a CryptoItemEventServiceAPI for any given ERC20 token.
    fileprivate static func erc20(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI {
        let erc20EventsService = ERC20TransactionalActivityItemEventsService(cryptoCurrency: cryptoCurrency)
        return custodialNonCustodial(currency: cryptoCurrency, eventsService: erc20EventsService)
    }

    /// Returns a CryptoItemEventServiceAPI for a custodial only currency.
    private static func custodial(
        currency: CryptoCurrency,
        transactionalService: EmptyTransactionalActivityItemEventService = resolve()
    ) -> CryptoItemEventServiceAPI {
        buildCryptoItemEventService(
            currency: currency,
            eventsService: transactionalService
        )
    }

    /// Returns a CryptoItemEventServiceAPI for a currency that has both custodial and non custodial support.
    private static func custodialNonCustodial(
        currency: CryptoCurrency,
        eventsService: TransactionalActivityItemEventFetcherAPI
    ) -> CryptoItemEventServiceAPI {
        buildCryptoItemEventService(
            currency: currency,
            eventsService: TransactionalActivityItemEventService(fetcher: eventsService)
        )
    }

    /// Builds a CryptoItemEventServiceAPI with the given dependencies.
    private static func buildCryptoItemEventService(
        currency: CryptoCurrency,
        eventsService: TransactionalActivityItemEventServiceAPI,
        orderService: OrdersServiceAPI = resolve(),
        swapActivity: SwapActivityServiceAPI = resolve()
    ) -> CryptoItemEventServiceAPI {
        let fetcher = SwapActivityItemEventsService(currency: currency, service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        let buySell = BuySellActivityItemEventService(currency: currency, service: orderService)
        return CryptoEventService(
            transactional: eventsService,
            buySell: buySell,
            swap: swapService
        )
    }
}

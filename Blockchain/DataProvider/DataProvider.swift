// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import InterestKit
import PlatformKit
import RxRelay
import RxSwift

/// A container for common crypto services.
/// Rule of thumb: If a service may be used by multiple clients,
/// and if there should be a single service per asset, it makes sense to place
/// that it inside a specialized container.
final class DataProvider: DataProviding {

    /// The default container
    @Inject static var `default`: DataProvider

    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding

    /// Exchange service for any asset
    let exchange: ExchangeProviding

    /// Balance change service
    let balanceChange: BalanceChangeProviding

    /// Balance service for any asset
    let balance: BalanceProviding

    let syncing: PortfolioSyncingService

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

        let tradingBalanceStatesFetcher = CustodialBalanceStatesFetcher(
            tradingBalanceService: resolve()
        )

        let savingsBalanceStatesFetcher = CustodialBalanceStatesFetcher(
            savingAccountService: resolve()
        )

        var fiatBalanceFetchers: [FiatCurrency: AssetBalanceFetching] = [:]
        for fiatCurrency in enabledCurrencies.allEnabledFiatCurrencies {
            let currencyType = CurrencyType.fiat(fiatCurrency)
            fiatBalanceFetchers[fiatCurrency] = AssetBalanceFetcher(
                blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: currencyType),
                wallet: AbsentAccountBalanceFetching(
                    currencyType: currencyType,
                    accountType: .custodial(.trading)
                ),
                trading: CustodialMoneyBalanceFetcher(
                    currencyType: currencyType,
                    fetcher: tradingBalanceStatesFetcher
                ),
                savings: AbsentAccountBalanceFetching(
                    currencyType: currencyType,
                    accountType: .custodial(.savings)
                ),
                exchange: exchange[fiatCurrency]
            )
        }

        let algorandBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.algorand)),
            wallet: AbsentAccountBalanceFetching(
                currencyType: CurrencyType.crypto(.algorand),
                accountType: .nonCustodial
            ),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.algorand.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.algorand.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.algorand)]
        )
        let polkadotBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.polkadot)),
            wallet: AbsentAccountBalanceFetching(
                currencyType: CurrencyType.crypto(.polkadot),
                accountType: .nonCustodial
            ),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.polkadot.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.polkadot.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.polkadot)]
        )

        let etherBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.ethereum)),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.ethereum) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.ethereum.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.ethereum.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.ethereum)]
        )

        let paxBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.erc20(.pax))),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.erc20(.pax)) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.pax).currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.pax).currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.erc20(.pax))]
        )
        let tetherBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.erc20(.tether))),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.erc20(.tether)) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.tether).currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.tether).currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.erc20(.tether))]
        )
        let wDGLDBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.erc20(.wdgld))),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.erc20(.wdgld)) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.wdgld).currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.wdgld).currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.erc20(.wdgld))]
        )
        let yearnFinanceBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.erc20(.yearnFinance))),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.erc20(.yearnFinance)) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.yearnFinance).currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.yearnFinance).currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.erc20(.yearnFinance))]
        )
        let aaveBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.erc20(.aave))),
            wallet: { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.erc20(.aave)) }(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.aave).currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.erc20(.aave).currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.erc20(.aave))]
        )
        let stellarBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.stellar)),
            wallet: StellarServiceProvider.shared.services.accounts,
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.stellar.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.stellar.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.stellar)]
        )
        let bitcoinBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.bitcoin)),
            wallet: BitcoinAllAccountsBalanceFetcher(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.bitcoin.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.bitcoin.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.bitcoin)]
        )
        let bitcoinCashBalanceFetcher = AssetBalanceFetcher(
            blockchainAccountFetcher: BlockchainAccountFetchingFactory.make(for: .crypto(.bitcoinCash)),
            wallet: BitcoinCashAssetBalanceFetcher(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.bitcoinCash.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.bitcoinCash.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.bitcoinCash)]
        )

        let cryptoBalanceFetchers: [CryptoCurrency: AssetBalanceFetching] = [
            .erc20(.aave): aaveBalanceFetcher,
            .algorand: algorandBalanceFetcher,
            .bitcoin: bitcoinBalanceFetcher,
            .bitcoinCash: bitcoinCashBalanceFetcher,
            .ethereum: etherBalanceFetcher,
            .erc20(.pax): paxBalanceFetcher,
            .polkadot: polkadotBalanceFetcher,
            .stellar: stellarBalanceFetcher,
            .erc20(.tether): tetherBalanceFetcher,
            .erc20(.wdgld): wDGLDBalanceFetcher,
            .erc20(.yearnFinance): yearnFinanceBalanceFetcher
        ]

        let balance = BalanceProvider(
            fiats: fiatBalanceFetchers,
            cryptos: cryptoBalanceFetchers
        )

        self.balance = balance

        balanceChange = BalanceChangeProvider(
            currencies: enabledCurrencies.allEnabledCryptoCurrencies,
            aave: AssetBalanceChangeProvider(
                balance: aaveBalanceFetcher,
                prices: historicalPrices[.erc20(.aave)],
                cryptoCurrency: .erc20(.aave)
            ),
            algorand: AssetBalanceChangeProvider(
                balance: algorandBalanceFetcher,
                prices: historicalPrices[.algorand],
                cryptoCurrency: .algorand
            ),
            bitcoin: AssetBalanceChangeProvider(
                balance: bitcoinBalanceFetcher,
                prices: historicalPrices[.bitcoin],
                cryptoCurrency: .bitcoin
            ),
            bitcoinCash: AssetBalanceChangeProvider(
                balance: bitcoinCashBalanceFetcher,
                prices: historicalPrices[.bitcoinCash],
                cryptoCurrency: .bitcoinCash
            ),
            ether: AssetBalanceChangeProvider(
                balance: etherBalanceFetcher,
                prices: historicalPrices[.ethereum],
                cryptoCurrency: .ethereum
            ),
            pax: AssetBalanceChangeProvider(
                balance: paxBalanceFetcher,
                prices: historicalPrices[.erc20(.pax)],
                cryptoCurrency: .erc20(.pax)
            ),
            polkadot: AssetBalanceChangeProvider(
                balance: polkadotBalanceFetcher,
                prices: historicalPrices[.polkadot],
                cryptoCurrency: .polkadot
            ),
            stellar: AssetBalanceChangeProvider(
                balance: stellarBalanceFetcher,
                prices: historicalPrices[.stellar],
                cryptoCurrency: .stellar
            ),
            tether: AssetBalanceChangeProvider(
                balance: tetherBalanceFetcher,
                prices: historicalPrices[.erc20(.tether)],
                cryptoCurrency: .erc20(.tether)
            ),
            wDGLD: AssetBalanceChangeProvider(
                balance: wDGLDBalanceFetcher,
                prices: historicalPrices[.erc20(.wdgld)],
                cryptoCurrency: .erc20(.wdgld)
            ),
            yearnFinance: AssetBalanceChangeProvider(
                balance: yearnFinanceBalanceFetcher,
                prices: historicalPrices[.erc20(.yearnFinance)],
                cryptoCurrency: .erc20(.yearnFinance)
            )
        )

        syncing = .init(
            balanceProviding: balance,
            balanceChangeProviding: balanceChange,
            fiatCurrencyProviding: fiatCurrencyService
        )
    }
}

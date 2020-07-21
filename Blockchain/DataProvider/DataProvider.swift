//
//  DataProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import ERC20Kit
import PlatformKit
import BuySellKit
import RxRelay
import RxSwift

/// A container for common crypto services.
/// Rule of thumb: If a service may be used by multiple clients,
/// and if there should be a single service per asset, it makes sense to place
/// that it inside a specialized container.
final class DataProvider: DataProviding {
        
    /// The default container
    static let `default` = DataProvider()
    
    /// Historical service that provides past prices for a given asset type
    let historicalPrices: HistoricalFiatPriceProviding
    
    /// Exchange service for any asset
    let exchange: ExchangeProviding
    
    /// Balance change service
    let balanceChange: BalanceChangeProviding
    
    /// Balance service for any asset
    let balance: BalanceProviding
        
    /// BuySellKit service provider
    let buySell: BuySellKit.ServiceProviderAPI
    
    init(featureFetching: FeatureFetching = AppFeatureConfigurator.shared,
         kycTierService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         custodialClient: CustodialClientAPI = CustodialClient(),
         savingsAccountClient: SavingsAccountClientAPI = SavingsAccountClient(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         supportedCustodialFiatCurrencies: [FiatCurrency] = CustodialLocallySupportedFiatCurrencies.fiatCurrencies) {
                
        var fiatExchangeServices: [FiatCurrency: PairExchangeServiceAPI] = [:]
        for fiatCurrency in supportedCustodialFiatCurrencies {
            fiatExchangeServices[fiatCurrency] = PairExchangeService(
                currency: fiatCurrency,
                fiatCurrencyService: fiatCurrencyService
            )
        }
        
        self.exchange = ExchangeProvider(
            fiats: fiatExchangeServices,
            algorand: PairExchangeService(
                cryptoCurrency: CryptoCurrency.algorand,
                fiatCurrencyService: fiatCurrencyService
            ),
            ether: PairExchangeService(
                cryptoCurrency: CryptoCurrency.ethereum,
                fiatCurrencyService: fiatCurrencyService
            ),
            pax: PairExchangeService(
                cryptoCurrency: CryptoCurrency.pax,
                fiatCurrencyService: fiatCurrencyService
            ),
            stellar: PairExchangeService(
                cryptoCurrency: CryptoCurrency.stellar,
                fiatCurrencyService: fiatCurrencyService
            ),
            bitcoin: PairExchangeService(
                cryptoCurrency: CryptoCurrency.bitcoin,
                fiatCurrencyService: fiatCurrencyService
            ),
            bitcoinCash: PairExchangeService(
                cryptoCurrency: CryptoCurrency.bitcoinCash,
                fiatCurrencyService: fiatCurrencyService
            ),
            tether: PairExchangeService(
                cryptoCurrency: .tether,
                fiatCurrencyService: fiatCurrencyService
            )
        )

        let algorandHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .algorand,
            exchangeAPI: exchange[CryptoCurrency.algorand],
            fiatCurrencyService: fiatCurrencyService
        )
        let etherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            exchangeAPI: exchange[CryptoCurrency.ethereum],
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
        let stellarHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            exchangeAPI: exchange[CryptoCurrency.stellar],
            fiatCurrencyService: fiatCurrencyService
        )
        let paxHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .pax,
            exchangeAPI: exchange[CryptoCurrency.pax],
            fiatCurrencyService: fiatCurrencyService
        )
        let tetherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .tether,
            exchangeAPI: exchange[CryptoCurrency.tether],
            fiatCurrencyService: fiatCurrencyService
        )
        
        self.historicalPrices = HistoricalFiatPriceProvider(
            algorand: algorandHistoricalFiatService,
            ether: etherHistoricalFiatService,
            pax: paxHistoricalFiatService,
            stellar: stellarHistoricalFiatService,
            bitcoin: bitcoinHistoricalFiatService,
            bitcoinCash: bitcoinCashHistoricalFiatService,
            tether: tetherHistoricalFiatService
        )
                
        let tradingBalanceStatesFetcher = CustodialBalanceStatesFetcher(
            service: TradingBalanceService(
                client: custodialClient
            )
        )
        
        let savingsBalanceStatesFetcher = CustodialBalanceStatesFetcher(
            service: SavingAccountService(
                client: savingsAccountClient,
                custodialFeatureFetcher: CustodialFeatureFetcher(
                    tiersService: kycTierService,
                    featureFetching: featureFetching
                )
            )
        )
        
        var fiatBalanceFetchers: [FiatCurrency: AssetBalanceFetching] = [:]
        for fiatCurrency in supportedCustodialFiatCurrencies {
            let currencyType = CurrencyType.fiat(fiatCurrency)
            fiatBalanceFetchers[fiatCurrency] = AssetBalanceFetcher(
                wallet: AbsentAccountBalanceFetching(
                    currencyType: currencyType,
                    balanceType: .nonCustodial
                ),
                trading: CustodialMoneyBalanceFetcher(
                    currencyType: currencyType,
                    fetcher: tradingBalanceStatesFetcher
                ),
                savings: AbsentAccountBalanceFetching(
                    currencyType: currencyType,
                    balanceType: .custodial(.savings)
                ),
                exchange: exchange[fiatCurrency]
            )
        }
        
        let algorandBalanceFetcher = AssetBalanceFetcher(
            wallet: AbsentAccountBalanceFetching(
                currencyType: CurrencyType.crypto(.algorand),
                balanceType: .nonCustodial
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
        let etherBalanceFetcher = AssetBalanceFetcher(
            wallet: WalletManager.shared.wallet.ethereum,
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
            wallet: ERC20AssetBalanceFetcher<PaxToken>(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.pax.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.pax.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.pax)]
        )
        let tetherBalanceFetcher = AssetBalanceFetcher(
            wallet: ERC20AssetBalanceFetcher<TetherToken>(),
            trading: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.tether.currency,
                fetcher: tradingBalanceStatesFetcher
            ),
            savings: CustodialMoneyBalanceFetcher(
                currencyType: CryptoCurrency.tether.currency,
                fetcher: savingsBalanceStatesFetcher
            ),
            exchange: exchange[CurrencyType.crypto(.tether)]
        )
        let stellarBalanceFetcher = AssetBalanceFetcher(
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
            wallet: BitcoinAssetBalanceFetcher(bridge: WalletManager.shared.wallet.bitcoin),
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
            .bitcoin : bitcoinBalanceFetcher,
            .bitcoinCash : bitcoinCashBalanceFetcher,
            .stellar : stellarBalanceFetcher,
            .pax : paxBalanceFetcher,
            .ethereum : etherBalanceFetcher,
            .algorand : algorandBalanceFetcher,
            .tether : tetherBalanceFetcher
        ]
        
        let balance = BalanceProvider(
            fiats: fiatBalanceFetchers,
            cryptos: cryptoBalanceFetchers
        )
        
        self.balance = balance
        
        balanceChange = BalanceChangeProvider(
            currencies: CryptoCurrency.allEnabled,
            ether: AssetBalanceChangeProvider(
                balance: etherBalanceFetcher,
                prices: historicalPrices[.ethereum],
                cryptoCurrency: .ethereum
            ),
            pax: AssetBalanceChangeProvider(
                balance: paxBalanceFetcher,
                prices: historicalPrices[.pax],
                cryptoCurrency: .pax
            ),
            stellar: AssetBalanceChangeProvider(
                balance: stellarBalanceFetcher,
                prices: historicalPrices[.stellar],
                cryptoCurrency: .stellar
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
            algorand: AssetBalanceChangeProvider(
                balance: algorandBalanceFetcher,
                prices: historicalPrices[.algorand],
                cryptoCurrency: .algorand
            ),
            tether: AssetBalanceChangeProvider(
                balance: tetherBalanceFetcher,
                prices: historicalPrices[.tether],
                cryptoCurrency: .tether
            )
        )
        
        buySell = BuySellKit.ServiceProvider(balanceProvider: balance)
    }
}

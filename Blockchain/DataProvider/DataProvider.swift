//
//  DataProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
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
    
    init(fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared) {
        self.exchange = ExchangeProvider(
            ether: PairExchangeService(
                cryptoCurrency: .ethereum,
                fiatCurrencyService: fiatCurrencyService
            ),
            pax: PairExchangeService(
                cryptoCurrency: .pax,
                fiatCurrencyService: fiatCurrencyService
            ),
            stellar: PairExchangeService(
                cryptoCurrency: .stellar,
                fiatCurrencyService: fiatCurrencyService
            ),
            bitcoin: PairExchangeService(
                cryptoCurrency: .bitcoin,
                fiatCurrencyService: fiatCurrencyService
            ),
            bitcoinCash: PairExchangeService(
                cryptoCurrency: .bitcoinCash,
                fiatCurrencyService: fiatCurrencyService
            )
        )
        
        let etherHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .ethereum,
            exchangeAPI: exchange[.ethereum],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoin,
            exchangeAPI: exchange[.bitcoin],
            fiatCurrencyService: fiatCurrencyService
        )
        let bitcoinCashHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .bitcoinCash,
            exchangeAPI: exchange[.bitcoinCash],
            fiatCurrencyService: fiatCurrencyService
        )
        let stellarHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .stellar,
            exchangeAPI: exchange[.stellar],
            fiatCurrencyService: fiatCurrencyService
        )
        let paxHistoricalFiatService = HistoricalFiatPriceService(
            cryptoCurrency: .pax,
            exchangeAPI: exchange[.pax],
            fiatCurrencyService: fiatCurrencyService
        )
        
        self.historicalPrices = HistoricalFiatPriceProvider(
            ether: etherHistoricalFiatService,
            pax: paxHistoricalFiatService,
            stellar: stellarHistoricalFiatService,
            bitcoin: bitcoinHistoricalFiatService,
            bitcoinCash: bitcoinCashHistoricalFiatService
        )
        
        let custodialBalanceService = CustodialBalanceService(
            client: CustodialBalanceClient(),
            authenticationService: authenticationService
        )
        
        let etherBalanceFetcher = AssetBalanceFetcher(
            custodialBalance: CustodialCryptoBalanceFetcher(
                currencyType: .ethereum,
                service: custodialBalanceService
            ),
            balance: WalletManager.shared.wallet.ethereum,
            exchange: exchange[.ethereum]
        )
        let paxBalanceFetcher = AssetBalanceFetcher(
            custodialBalance: CustodialCryptoBalanceFetcher(
                currencyType: .pax,
                service: custodialBalanceService
            ),
            balance: ERC20AssetBalanceFetcher(),
            exchange: exchange[.pax]
        )
        let stellarBalanceFetcher = AssetBalanceFetcher(
            custodialBalance: CustodialCryptoBalanceFetcher(
                currencyType: .stellar,
                service: custodialBalanceService
            ),
            balance: StellarServiceProvider.shared.services.accounts,
            exchange: exchange[.stellar]
        )
        let bitcoinBalanceFetcher = AssetBalanceFetcher(
            custodialBalance: CustodialCryptoBalanceFetcher(
                currencyType: .bitcoin,
                service: custodialBalanceService
            ),
            balance: BitcoinAssetBalanceFetcher(),
            exchange: exchange[.bitcoin]
        )
        let bitcoinCashBalanceFetcher = AssetBalanceFetcher(
            custodialBalance: CustodialCryptoBalanceFetcher(
                currencyType: .bitcoinCash,
                service: custodialBalanceService
            ),
            balance: BitcoinCashAssetBalanceFetcher(),
            exchange: exchange[.bitcoinCash]
        )
        
        balance = BalanceProvider(
            ether: etherBalanceFetcher,
            pax: paxBalanceFetcher,
            stellar: stellarBalanceFetcher,
            bitcoin: bitcoinBalanceFetcher,
            bitcoinCash: bitcoinCashBalanceFetcher
        )
        
        balanceChange = BalanceChangeProvider(
            ether: AssetBalanceChangeProvider(
                balance: etherBalanceFetcher,
                prices: historicalPrices[.ethereum]
            ),
            pax: AssetBalanceChangeProvider(
                balance: paxBalanceFetcher,
                prices: historicalPrices[.pax]
            ),
            stellar: AssetBalanceChangeProvider(
                balance: stellarBalanceFetcher,
                prices: historicalPrices[.stellar]
            ),
            bitcoin: AssetBalanceChangeProvider(
                balance: bitcoinBalanceFetcher,
                prices: historicalPrices[.bitcoin]
            ),
            bitcoinCash: AssetBalanceChangeProvider(
                balance: bitcoinCashBalanceFetcher,
                prices: historicalPrices[.bitcoinCash]
            )
        )
    }
}

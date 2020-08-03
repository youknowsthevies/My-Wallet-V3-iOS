//
//  Activity.swift
//  Blockchain
//
//  Created by Daniel on 08/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BuySellKit
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit
import BitcoinKit

protocol ActivityServiceProviderAPI: AnyObject {
    
    var ethereumDetails: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> { get }
    var stellarDetails: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> { get }
    var bitcoinDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> { get }
    var bitcoinCashDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> { get }
    var activity: ActivityProviding { get }
}

final class ActivityServiceProvider: ActivityServiceProviderAPI {
    
    static let `default` = ActivityServiceProvider()
        
    let ethereumDetails: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    let stellarDetails: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails>
    let bitcoinDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>
    let bitcoinCashDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails>
    let activity: ActivityProviding
    
    init(bitcoinCashServices: BitcoinCashDependencies = BitcoinCashServiceProvider.shared.services,
         bitcoinServices: BitcoinDependencies = BitcoinServiceProvider.shared.services,
         stellarServices: StellarDependenciesAPI = StellarServiceProvider.shared.services,
         ethServices: ETHDependencies = ETHServiceProvider.shared.services,
         paxServices: PAXDependencies = PAXServiceProvider.shared.services,
         tetherServices: TetherDependencies = TetherServiceProvider.shared.services,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         simpleBuyOrdersAPI: BuySellKit.OrdersServiceAPI = DataProvider.default.buySell.ordersDetails,
         simpleBuyActivityService: FiatActivityItemEventFetcherAPI = DataProvider.default.buySell.fiatActivity,
         swapActivityAPI: SwapActivityServiceAPI = resolve()) {
        let pax: ActivityItemEventServiceAPI = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: AnyERC20TransactionalActivityItemEventsService<PaxToken>(
                    transactionsService: paxServices.historicalTransactionService
                )
            ),
            buy: BuyActivityItemEventService(currency: .pax, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: AnyERC20SwapActivityItemEventsService<PaxToken>(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        
        let ethereum: ActivityItemEventServiceAPI = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: EthereumTransactionalActivityItemEventsService(transactionsService: ethServices.transactionService)
            ),
            buy: BuyActivityItemEventService(currency: .ethereum, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: EthereumSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        ethereumDetails = AnyActivityItemEventDetailsFetcher(
            api: EthereumActivityItemEventDetailsFetcher(transactionService: ethServices.transactionService)
        )
        
        let stellar: ActivityItemEventServiceAPI = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: StellarTransactionalActivityItemEventsService(repository: stellarServices.repository)
            ),
            buy: BuyActivityItemEventService(currency: .stellar, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: StellarSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        stellarDetails = AnyActivityItemEventDetailsFetcher(
            api: StellarActivityItemEventDetailsFetcher(repository: stellarServices.repository)
        )
        
        bitcoinDetails = AnyActivityItemEventDetailsFetcher(
            api: BitcoinActivityItemEventDetailsFetcher(transactionService: bitcoinServices.transactions)
        )
        let bitcoin: ActivityItemEventServiceAPI = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: BitcoinTransactionalActivityItemEventsService(transactionsService: bitcoinServices.transactions)
            ),
            buy: BuyActivityItemEventService(currency: .bitcoin, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: BitcoinSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        
        let bitcoinCash: ActivityItemEventServiceAPI = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: BitcoinCashTransactionalActivityItemEventsService(transactionsService: bitcoinCashServices.transactions)
            ),
            buy: BuyActivityItemEventService(currency: .bitcoinCash, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: BitcoinCashSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        bitcoinCashDetails = AnyActivityItemEventDetailsFetcher(
            api: BitcoinCashActivityItemEventDetailsFetcher(transactionService: bitcoinCashServices.transactions)
        )
        
        let algorand = CryptoEventService(
            transactional: EmptyTransactionalActivityItemEventService(),
            buy: BuyActivityItemEventService(currency: .algorand, service: simpleBuyOrdersAPI),
            swap: EmptySwapActivityItemEventService()
        )
        
        let tether = CryptoEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: AnyERC20TransactionalActivityItemEventsService<TetherToken>(transactionsService: tetherServices.historicalTransactionService)
            ),
            buy: BuyActivityItemEventService(currency: .tether, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: AnyERC20SwapActivityItemEventsService<TetherToken>(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
        
        let euroFiatActivity = FiatActivityItemEventService(
            fetcher: simpleBuyActivityService,
            fiatCurrency: .EUR
        )
        
        let gbpFiatActivity = FiatActivityItemEventService(
            fetcher: simpleBuyActivityService,
            fiatCurrency: .GBP
        )
        
        let euro = FiatEventService(fiat: euroFiatActivity)
        let gbp = FiatEventService(fiat: gbpFiatActivity)
        
        activity = ActivityProvider(
            fiats: [
                .EUR: euro,
                .GBP: gbp
            ],
            cryptos: [
                .algorand : algorand,
                .ethereum: ethereum,
                .pax: pax,
                .stellar: stellar,
                .bitcoin: bitcoin,
                .bitcoinCash: bitcoinCash,
                .tether: tether
            ]
        )
    }
}


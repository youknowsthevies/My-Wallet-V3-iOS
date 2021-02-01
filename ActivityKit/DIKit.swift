//
//  DIKit.swift
//  ActivityKit
//
//  Created by Dimitrios Chatzieleftheriou on 22/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AlgorandKit
import BitcoinCashKit
import BitcoinKit
import BuySellKit
import DIKit
import ERC20Kit
import EthereumKit
import PlatformKit
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
            
            let cryptos: [CryptoCurrency: CryptoItemEventServiceAPI] = [
                .algorand: DIKit.resolve(tag: CryptoCurrency.algorand),
                .bitcoin: DIKit.resolve(tag: CryptoCurrency.bitcoin),
                .bitcoinCash: DIKit.resolve(tag: CryptoCurrency.bitcoinCash),
                .tether: DIKit.resolve(tag: CryptoCurrency.tether),
                .pax: DIKit.resolve(tag: CryptoCurrency.pax),
                .ethereum: DIKit.resolve(tag: CryptoCurrency.ethereum),
                .stellar: DIKit.resolve(tag: CryptoCurrency.stellar),
                .wDGLD: DIKit.resolve(tag: CryptoCurrency.wDGLD)
            ]
            
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
        
        factory(tag: CryptoCurrency.algorand) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.algorand()
        }
        
        factory(tag: CryptoCurrency.bitcoin) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.bitcoin()
        }
        
        factory(tag: CryptoCurrency.bitcoinCash) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.bitcoinCash()
        }
        
        factory(tag: CryptoCurrency.tether) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.tether()
        }
        
        factory(tag: CryptoCurrency.pax) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.pax()
        }
        
        factory(tag: CryptoCurrency.ethereum) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.ethereum()
        }
        
        factory(tag: CryptoCurrency.stellar) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.stellar()
        }

        factory(tag: CryptoCurrency.wDGLD) { () -> CryptoItemEventServiceAPI in
            CryptoEventService.wDGLD()
        }
    }
}

extension CryptoEventService {
    fileprivate static func algorand(transactional: EmptyTransactionalActivityItemEventService = resolve(),
                                     orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                     swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let fetcher = AlgorandSwapActivityItemEventsService(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        let buySell = BuySellActivityItemEventService(currency: .algorand, service: orderService)
        return CryptoEventService(transactional: transactional,
                                  buySell: buySell,
                                  swap: swapService)
    }
    
    fileprivate static func bitcoin(eventsService: BitcoinTransactionalActivityItemEventsService = resolve(),
                                    orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                    swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let transactionalService = TransactionalActivityItemEventService(fetcher: eventsService)
        let buySell = BuySellActivityItemEventService(currency: .bitcoin, service: orderService)
        let fetcher = BitcoinSwapActivityItemEventsService(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
    }
    
    fileprivate static func bitcoinCash(eventsService: BitcoinCashTransactionalActivityItemEventsService = resolve(),
                                        orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                        swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let transactionalService = TransactionalActivityItemEventService(fetcher: eventsService)
        let buySell = BuySellActivityItemEventService(currency: .bitcoinCash, service: orderService)
        let fetcher = BitcoinCashSwapActivityItemEventsService(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
    }
    
    fileprivate static func ethereum(eventsService: EthereumTransactionalActivityItemEventsService = resolve(),
                                     orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                     swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        
        let transactionalService = TransactionalActivityItemEventService(fetcher: eventsService)
        let buySell = BuySellActivityItemEventService(currency: .ethereum, service: orderService)
        let fetcher = EthereumSwapActivityItemEventsService(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
        
    }
    
    fileprivate static func stellar(eventsService: StellarTransactionalActivityItemEventsService = resolve(),
                                    orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                    swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        
        let transactionalService = TransactionalActivityItemEventService(fetcher: eventsService)
        let buySell = BuySellActivityItemEventService(currency: .stellar, service: orderService)
        let fetcher = StellarSwapActivityItemEventsService(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
        
    }

    fileprivate static func tether(historalTransactionService: AnyERC20HistoricalTransactionService<TetherToken> = resolve(),
                                   eventsService: BitcoinCashTransactionalActivityItemEventsService = resolve(),
                                   orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                   swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let erc20EventsService = AnyERC20TransactionalActivityItemEventsService<TetherToken>(transactionsService: historalTransactionService)
        
        let transactionalService = TransactionalActivityItemEventService(fetcher: erc20EventsService)
        let buySell = BuySellActivityItemEventService(currency: .tether, service: orderService)
        
        let fetcher = AnyERC20SwapActivityItemEventsService<TetherToken>(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
    }

    fileprivate static func wDGLD(historalTransactionService: AnyERC20HistoricalTransactionService<WDGLDToken> = resolve(),
                                  eventsService: BitcoinCashTransactionalActivityItemEventsService = resolve(),
                                  orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                  swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let erc20EventsService = AnyERC20TransactionalActivityItemEventsService<WDGLDToken>(transactionsService: historalTransactionService)

        let transactionalService = TransactionalActivityItemEventService(fetcher: erc20EventsService)
        let buySell = BuySellActivityItemEventService(currency: .wDGLD, service: orderService)

        let fetcher = AnyERC20SwapActivityItemEventsService<WDGLDToken>(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
    }
    
    fileprivate static func pax(historalTransactionService: AnyERC20HistoricalTransactionService<PaxToken> = resolve(),
                                eventsService: BitcoinCashTransactionalActivityItemEventsService = resolve(),
                                orderService: BuySellKit.OrdersServiceAPI = resolve(),
                                swapActivity: SwapActivityServiceAPI = resolve()) -> CryptoEventService {
        let erc20EventsService = AnyERC20TransactionalActivityItemEventsService<PaxToken>(transactionsService: historalTransactionService)
        
        let transactionalService = TransactionalActivityItemEventService(fetcher: erc20EventsService)
        let buySell = BuySellActivityItemEventService(currency: .pax, service: orderService)
        
        let fetcher = AnyERC20SwapActivityItemEventsService<PaxToken>(service: swapActivity)
        let swapService = SwapActivityItemEventService(fetcher: fetcher)
        return CryptoEventService(
            transactional: transactionalService,
            buySell: buySell,
            swap: swapService
        )
    }
}

//
//  BitcoinCashServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import BuySellKit
import PlatformKit

protocol BitcoinCashDependencies {
    var transactions: BitcoinCashHistoricalTransactionService { get }
    var activity: ActivityItemEventServiceAPI { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> { get }
}

struct BitcoinCashServices: BitcoinCashDependencies {
    let transactions: BitcoinCashHistoricalTransactionService
    let activity: ActivityItemEventServiceAPI
    let activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails>

    init(bridge: BitcoinCashWalletBridgeAPI = BitcoinCashWallet(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         simpleBuyOrdersAPI: BuySellKit.OrdersServiceAPI = ServiceProvider.default.ordersDetails,
         swapActivityAPI: SwapActivityServiceAPI = SwapServiceProvider.default.activity) {
        transactions = .init(
            bridge: bridge
        )
        activityDetails = .init(
            api: BitcoinCashActivityItemEventDetailsFetcher(transactionService: transactions)
        )
        activity = ActivityItemEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: BitcoinCashTransactionalActivityItemEventsService(transactionsService: transactions)
            ),
            buy: BuyActivityItemEventService(currency: .bitcoinCash, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: BitcoinCashSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
    }
}

final class BitcoinCashServiceProvider {
    
    let services: BitcoinCashDependencies
    
    static let shared = BitcoinCashServiceProvider.make()
    
    class func make() -> BitcoinCashServiceProvider {
        BitcoinCashServiceProvider(services: BitcoinCashServices())
    }
    
    init(services: BitcoinCashDependencies) {
        self.services = services
    }
    
    var transactions: BitcoinCashHistoricalTransactionService {
        services.transactions
    }
    
    var activity: ActivityItemEventServiceAPI {
        services.activity
    }
}


//
//  BitcoinServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import BuySellKit
import PlatformKit

protocol BitcoinDependencies {
    var transactions: BitcoinHistoricalTransactionService { get }
    var activity: ActivityItemEventServiceAPI { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> { get }
}

struct BitcoinServices: BitcoinDependencies {
    let transactions: BitcoinHistoricalTransactionService
    let activity: ActivityItemEventServiceAPI
    let activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>

    init(bridge: BitcoinWalletBridgeAPI = WalletManager.shared.wallet.bitcoin,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         simpleBuyOrdersAPI: SimpleBuyOrdersServiceAPI = SimpleBuyServiceProvider.default.ordersDetails,
         swapActivityAPI: SwapActivityServiceAPI = SwapServiceProvider.default.activity,
         client: BitcoinKit.APIClient = BitcoinKit.APIClient()) {
        transactions = .init(
            with: client,
            bridge: bridge
        )
        activityDetails = .init(
            api: BitcoinActivityItemEventDetailsFetcher(transactionService: transactions)
        )
        activity = ActivityItemEventService(
            transactional: TransactionalActivityItemEventService(
                fetcher: BitcoinTransactionalActivityItemEventsService(transactionsService: transactions)
            ),
            buy: BuyActivityItemEventService(currency: .bitcoin, service: simpleBuyOrdersAPI),
            swap: SwapActivityItemEventService(
                fetcher: BitcoinSwapActivityItemEventsService(service: swapActivityAPI),
                fiatCurrencyProvider: fiatCurrencyService
            )
        )
    }
}

final class BitcoinServiceProvider {
    
    let services: BitcoinDependencies
    
    static let shared = BitcoinServiceProvider.make()
    
    class func make() -> BitcoinServiceProvider {
        BitcoinServiceProvider(services: BitcoinServices())
    }
    
    init(services: BitcoinDependencies) {
        self.services = services
    }
    
    var activity: ActivityItemEventServiceAPI {
        services.activity
    }
    
    var transactions: BitcoinHistoricalTransactionService {
        services.transactions
    }
}

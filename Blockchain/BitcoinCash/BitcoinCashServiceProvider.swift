//
//  BitcoinCashServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import PlatformKit

protocol BitcoinCashDependencies {
    var transactions: BitcoinCashHistoricalTransactionService { get }
    var activity: BitcoinCashActivityItemEventFetcher { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails> { get }
}

struct BitcoinCashServices: BitcoinCashDependencies {
    let transactions: BitcoinCashHistoricalTransactionService
    let activity: BitcoinCashActivityItemEventFetcher
    let activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinCashActivityItemEventDetails>

    init(bridge: BitcoinCashWalletBridgeAPI = BitcoinCashWallet(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         client: BitcoinKit.APIClient = BitcoinKit.APIClient(),
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared) {
        transactions = .init(
            with: client,
            bridge: bridge
        )
        activityDetails = .init(
            api: BitcoinCashActivityItemEventDetailsFetcher(transactionService: transactions)
        )
        activity = .init(
            swapActivityEventService: .init(
                service: SwapActivityService(
                    authenticationService: authenticationService,
                    fiatCurrencyProvider: fiatCurrencyService
                )
            ),
            transactionalActivityEventService: .init(
                transactionsService: transactions
            ),
            fiatCurrencyProvider: fiatCurrencyService
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
    
    var activity: BitcoinCashActivityItemEventFetcher {
        services.activity
    }
}


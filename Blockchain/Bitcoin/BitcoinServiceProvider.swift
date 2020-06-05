//
//  BitcoinServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import PlatformKit

protocol BitcoinDependencies {
    var transactions: BitcoinHistoricalTransactionService { get }
    var activity: BitcoinActivityItemEventFetcher { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> { get }
}

struct BitcoinServices: BitcoinDependencies {
    let transactions: BitcoinHistoricalTransactionService
    let activity: BitcoinActivityItemEventFetcher
    let activityDetails: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>

    init(bridge: BitcoinWalletBridgeAPI = WalletManager.shared.wallet.bitcoin,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         client: BitcoinKit.APIClient = BitcoinKit.APIClient()) {
        transactions = .init(
            with: client,
            bridge: bridge
        )
        activityDetails = .init(
            api: BitcoinActivityItemEventDetailsFetcher(transactionService: transactions)
        )
        self.activity = .init(
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

final class BitcoinServiceProvider {
    
    let services: BitcoinDependencies
    
    static let shared = BitcoinServiceProvider.make()
    
    class func make() -> BitcoinServiceProvider {
        BitcoinServiceProvider(services: BitcoinServices())
    }
    
    init(services: BitcoinDependencies) {
        self.services = services
    }
    
    var activity: BitcoinActivityItemEventFetcher {
        services.activity
    }
    
    var transactions: BitcoinHistoricalTransactionService {
        services.transactions
    }
}

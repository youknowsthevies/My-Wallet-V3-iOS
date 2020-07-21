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
}

struct BitcoinCashServices: BitcoinCashDependencies {
    let transactions: BitcoinCashHistoricalTransactionService

    init(bridge: BitcoinCashWalletBridgeAPI = BitcoinCashWallet()) {
        transactions = .init(
            bridge: bridge
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
}


//
//  BitcoinServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import DIKit
import BuySellKit
import PlatformKit

protocol BitcoinDependencies {
    var transactions: BitcoinHistoricalTransactionService { get }
}

struct BitcoinServices: BitcoinDependencies {
    let transactions: BitcoinHistoricalTransactionService

    init(transactions: BitcoinHistoricalTransactionService = resolve()) {
        self.transactions = transactions
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

    var transactions: BitcoinHistoricalTransactionService {
        services.transactions
    }
}

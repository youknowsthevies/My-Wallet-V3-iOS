//
//  EthereumOnChainTransactionEngineFactory.swift
//  EthereumKit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import TransactionKit

class EthereumOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        EthereumOnChainTransactionEngine(requireSecondPassword: requiresSecondPassword)
    }
}

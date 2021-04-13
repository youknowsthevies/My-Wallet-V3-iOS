//
//  StellarOnChainTransactionEngineFactory.swift
//  StellarKit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import TransactionKit

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(requireSecondPassword: requiresSecondPassword)
    }
}

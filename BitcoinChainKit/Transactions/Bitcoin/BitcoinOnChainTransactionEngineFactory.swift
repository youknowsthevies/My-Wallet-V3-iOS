//
//  BitcoinOnChainTransactionEngineFactory.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 12/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import TransactionKit

final class BitcoinOnChainTransactionEngineFactory<Token: BitcoinChainToken>: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        BitcoinOnChainTransactionEngine<Token>(requireSecondPassword: requiresSecondPassword)
    }
}

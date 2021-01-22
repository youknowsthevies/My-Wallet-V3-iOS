//
//  ERC20OnChainTransactionEngineFactory.swift
//  ERC20Kit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import TransactionKit

final class ERC20OnChainTransactionEngineFactory<Token: ERC20Token>: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        AnyERC20OnChainTransactionEngine<Token>(requireSecondPassword: requiresSecondPassword)
    }
}

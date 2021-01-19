//
//  OnChainTransactionEngineFactory.swift
//  TransactionKit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine
}

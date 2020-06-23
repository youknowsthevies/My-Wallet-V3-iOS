//
//  AccountBalanceState.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public typealias TradingAccountBalanceState = AccountBalanceState<TradingAccountBalance>
public typealias SavingsAccountBalanceState = AccountBalanceState<SavingsAccountBalance>

public enum AccountBalanceState<Value> {
    case absent
    case present(Value)
    
    public var balance: Value? {
        switch self {
        case .absent:
            return nil
        case .present(let balance):
            return balance
        }
    }
}

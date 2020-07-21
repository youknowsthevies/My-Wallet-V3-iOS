//
//  AccountBalanceState.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public typealias CustodialAccountBalanceState = AccountBalanceState<CustodialAccountBalance>

public enum AccountBalanceState<Value: Equatable>: Equatable {
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

public struct CustodialAccountBalanceStates: Equatable {
    
    // MARK: - Properties

    static var absent: CustodialAccountBalanceStates {
        CustodialAccountBalanceStates()
    }
    
    private var balances: [CurrencyType: CustodialAccountBalanceState] = [:]
    
    // MARK: - Subscript

    subscript(currency: CurrencyType) -> CustodialAccountBalanceState {
        get {
            balances[currency] ?? .absent
        }
        set {
            balances[currency] = newValue
        }
    }
}

extension CustodialAccountBalanceStates {
    
    // MARK: - Init

    init(response: SavingsAccountBalanceResponse) {
        for balanceResponse in response.balances {
            guard let cryptoCurrency = CryptoCurrency(code: balanceResponse.key) else { continue }
            guard let accountBalance = CustodialAccountBalance(currency: cryptoCurrency, response: balanceResponse.value) else {
                continue
            }
            balances[cryptoCurrency.currency] = .present(accountBalance)
        }
    }
    
    init(response: CustodialBalanceResponse) {
        for balanceResponse in response.balances {
            guard let currencyType = try? CurrencyType(currency: balanceResponse.key) else { continue }
            let accountBalance = CustodialAccountBalance(currency: currencyType, response: balanceResponse.value)
            balances[currencyType] = .present(accountBalance)
        }
    }
}

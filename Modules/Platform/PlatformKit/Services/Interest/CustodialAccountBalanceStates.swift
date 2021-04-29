// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public typealias CustodialAccountBalanceState = AccountBalanceState<CustodialAccountBalance>

public struct CustodialAccountBalanceStates: Equatable {
    
    // MARK: - Properties

    static var absent: CustodialAccountBalanceStates {
        CustodialAccountBalanceStates()
    }
    
    private var balances: [CurrencyType: CustodialAccountBalanceState] = [:]
    
    // MARK: - Subscript

    public subscript(currency: CurrencyType) -> CustodialAccountBalanceState {
        get {
            balances[currency] ?? .absent
        }
        set {
            balances[currency] = newValue
        }
    }
    
    // MARK: - Init
    
    public init(balances: [CurrencyType: CustodialAccountBalanceState] = [:]) {
        self.balances = balances
    }
}

extension CustodialAccountBalanceStates {
    
    // MARK: - Init
    
    init(response: CustodialBalanceResponse) {
        for balanceResponse in response.balances {
            guard let currencyType = try? CurrencyType(code: balanceResponse.key) else { continue }
            let accountBalance = CustodialAccountBalance(currency: currencyType, response: balanceResponse.value)
            balances[currencyType] = .present(accountBalance)
        }
    }
}

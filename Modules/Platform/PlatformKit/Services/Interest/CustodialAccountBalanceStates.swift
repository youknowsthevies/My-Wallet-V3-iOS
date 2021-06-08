// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

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

    init(response: CustodialBalanceResponse, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        balances = response.balances
            .reduce(into: [CurrencyType: CustodialAccountBalanceState]()) { (result, item) in
                guard let currencyType = try? CurrencyType(
                        code: item.key,
                        enabledCurrenciesService: enabledCurrenciesService) else {
                    return
                }
                let accountBalance = CustodialAccountBalance(currency: currencyType, response: item.value)
                result[currencyType] = .present(accountBalance)
            }
    }
}

//
//  CustodialAccountBalanceStates+Conveniences.swift
//  InterestKit
//
//  Created by Alex McGregor on 8/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension CustodialAccountBalanceStates {
    
    // MARK: - Init

    init(response: SavingsAccountBalanceResponse) {
        var values: [CurrencyType: CustodialAccountBalanceState] = [:]
        for balanceResponse in response.balances {
            guard let cryptoCurrency = CryptoCurrency(code: balanceResponse.key) else { continue }
            guard let accountBalance = CustodialAccountBalance(currency: cryptoCurrency, response: balanceResponse.value) else {
                continue
            }
            values[cryptoCurrency.currency] = .present(accountBalance)
        }
        self = .init(balances: values)
    }
}

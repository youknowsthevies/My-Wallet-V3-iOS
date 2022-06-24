// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct DelegatedCustodyBalances {
    public struct Balance {
        let index: Int
        let name: String
        let balance: MoneyValue
    }

    public let balances: [Balance]

    public func balance(index: Int, currency: CryptoCurrency) -> MoneyValue? {
        balances
            .first(where: { $0.index == index && $0.balance.currency == currency })
            .map(\.balance)
    }
}

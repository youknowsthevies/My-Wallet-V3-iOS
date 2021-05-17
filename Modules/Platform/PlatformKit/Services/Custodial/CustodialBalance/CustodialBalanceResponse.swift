// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CustodialBalanceResponse: Decodable {

    // MARK: - Types

    struct Balance: Decodable {
        let pending: String
        let pendingDeposit: String
        let pendingWithdrawal: String
        let available: String
        let withdrawable: String

        var totalPending: String {
            String((Int(pendingDeposit) ?? 0) - (Int(pendingWithdrawal) ?? 0))
        }

        static let zero = Balance(
            pending: "0",
            pendingDeposit: "0",
            pendingWithdrawal: "0",
            available: "0",
            withdrawable: "0"
        )
    }

    // MARK: - Properties

    let balances: [String: Balance]

    // MARK: - Init

    init(balances: [String: Balance]) {
        self.balances = balances
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        balances = try container.decode([String: Balance].self)
    }

    // MARK: - Subscript

    subscript(currencyType: CurrencyType) -> Balance? {
        balances[currencyType.code]
    }
}

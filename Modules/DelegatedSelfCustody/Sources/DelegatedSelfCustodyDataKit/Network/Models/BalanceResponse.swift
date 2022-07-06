// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BalanceResponse: Decodable {
    struct BalanceEntry: Decodable {
        struct Account: Decodable {
            let index: Int
            let name: String
        }

        struct CurrencyAmount: Decodable {
            let amount: String
            let precision: Int
        }

        let account: Account
        let amount: CurrencyAmount
        let unconfirmedAmount: CurrencyAmount
        let price: Int?
    }

    struct SubscriptionEntry: Decodable {
        let ticker: String
        let accounts: Int
        let pubkeyCount: Int
    }

    let balances: [BalanceEntry]
    let subscriptions: [SubscriptionEntry]
}

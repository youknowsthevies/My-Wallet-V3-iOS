// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct EVMBalancesResponse: Decodable {
    struct Balance: Decodable {
        let identifier: String
        let amount: String
    }

    struct Item: Decodable {
        let address: String
        let balances: [Balance]
    }

    let results: [Item]
}

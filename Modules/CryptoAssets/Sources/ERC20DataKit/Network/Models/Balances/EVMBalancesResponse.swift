// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct EVMBalancesResponse: Decodable {
    struct Balance: Decodable {
        let identifier: String
        let currency: String
        let balance: String
    }

    struct Item: Decodable {
        let address: String
        let balances: [Balance]
    }

    let results: [Item]
}

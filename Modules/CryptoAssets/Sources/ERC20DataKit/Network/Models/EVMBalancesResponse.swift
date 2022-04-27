// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct EVMBalancesResponse: Decodable {
    struct Item: Decodable {
        let identifier: String
        let amount: String
    }

    let address: String
    let balances: [Item]
}

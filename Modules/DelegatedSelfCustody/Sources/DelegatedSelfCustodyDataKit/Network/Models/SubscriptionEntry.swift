// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct SubscriptionEntry: Encodable {
    struct Account: Encodable {
        let index: Int
        let name: String
    }

    struct PubKey: Encodable {
        let pubkey: String
        let style: String
        let descriptor: Int
    }

    let currency: String
    let account: Account
    let pubkeys: [PubKey]
}

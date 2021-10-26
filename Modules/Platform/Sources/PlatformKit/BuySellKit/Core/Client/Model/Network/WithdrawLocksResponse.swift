// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct WithdrawLocksResponse: Decodable {

    struct Lock: Decodable {
        let expiresAt: String
        let amount: Amount
    }

    struct Amount: Decodable {
        let amount: String
        let currency: String
    }

    let locks: [Lock]
    let totalLocked: Amount
    let available: Amount
}

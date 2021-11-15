// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct WithdrawLocksCheckResponse: Decodable {

    struct Rule: Decodable {

        struct Attributes: Decodable {
            let tier: Int
        }

        let id: String
        let paymentMethod: String
        let lockTime: Int
        let isActive: Bool
        let attributes: Attributes
        let insertedAt: String
        let updatedAt: String
    }

    let rule: Rule?
}

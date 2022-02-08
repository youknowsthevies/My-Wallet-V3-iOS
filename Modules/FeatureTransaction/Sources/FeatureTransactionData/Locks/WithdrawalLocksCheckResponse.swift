// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct WithdrawalLocksCheckResponse: Decodable {

    struct WithdrawLocksRuleResponse: Decodable {
        let lockTime: Int
    }

    let rule: WithdrawLocksRuleResponse?
}

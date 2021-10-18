// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct InterestTransactionState: Equatable {
    var account: CryptoInterestAccount
    var action: AssetAction
}

extension InterestTransactionState {
    static func == (
        lhs: InterestTransactionState,
        rhs: InterestTransactionState
    ) -> Bool {
        lhs.action == rhs.action &&
            lhs.account.identifier == rhs.account.identifier
    }
}

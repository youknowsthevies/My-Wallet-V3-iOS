// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct InterestTransactionState: Equatable {
    var account: CryptoInterestAccount
    var action: AssetAction

    public init(
        account: CryptoInterestAccount,
        action: AssetAction
    ) {
        self.account = account
        self.action = action
    }
}

extension InterestTransactionState {
    public static func == (
        lhs: InterestTransactionState,
        rhs: InterestTransactionState
    ) -> Bool {
        lhs.action == rhs.action &&
            lhs.account.identifier == rhs.account.identifier
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WithdrawalLocksCheck {
    public init(lockDays: Int) {
        self.lockDays = lockDays
    }

    public let lockDays: Int
}

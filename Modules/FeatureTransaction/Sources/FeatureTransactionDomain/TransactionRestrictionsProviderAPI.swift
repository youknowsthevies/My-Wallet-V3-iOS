//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol TransactionRestrictionsProviderAPI {

    /// Returns `true` if the action can be performed with the specified account. E.g. if an action can only be performed on non-custodial accounts,
    /// this function should return `true` for that action and a non-custodial target, but `false` for the same action if the target is a custodial account.
    func canPerform(_ action: AssetAction, using target: TransactionTarget) -> Bool

    /// Returns the maximum number of transactions the user can perform for the specified action, if there's a limit, or `nil` otherwise.
    func maximumNumbersOfTransactions(for action: AssetAction) -> Int?
}

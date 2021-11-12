// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Use this struct to fill transaction data in `TransactionEngine`s.
public struct TransactionLimits {

    public let minimum: MoneyValue
    public let maximum: MoneyValue
    public let maximumDaily: MoneyValue
    public let maximumAnnual: MoneyValue
    public let suggestedUpgrade: SuggestedLimitsUpgrade?
}

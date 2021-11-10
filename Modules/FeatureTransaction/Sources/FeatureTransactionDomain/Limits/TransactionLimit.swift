// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct TransactionLimit {

    public let limit: MoneyValue
    public let available: MoneyValue
    public let used: MoneyValue

    public init(
        limit: MoneyValue,
        available: MoneyValue,
        used: MoneyValue
    ) {
        self.limit = limit
        self.available = available
        self.used = used
    }
}

// TODO: replace for TransactionLimit when API updates
public struct TimedLimit {
    let limit: MoneyValue
    let effective: Bool
}

public struct TimedLimits {
    let available: MoneyValue
    let daily: TimedLimit?
    let monthly: TimedLimit?
    let yearly: TimedLimit?
}

public struct SuggestedLimitsUpgrade {
    let requiredTier: KYC.Tier
    let available: MoneyValue?
    let daily: TimedLimit?
    let monthly: TimedLimit?
    let yearly: TimedLimit?
}

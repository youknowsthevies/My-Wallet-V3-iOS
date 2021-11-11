// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct TradeLimit {

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

public struct PeriodicLimit: Decodable {

    let limit: MoneyValue
    let effective: Bool?
}

public struct PeriodicLimits: Decodable {

    let available: MoneyValue
    let daily: PeriodicLimit?
    let monthly: PeriodicLimit?
    let yearly: PeriodicLimit?
}

public struct SuggestedLimitsUpgrade: Decodable {

    let requiredTier: KYC.Tier
    let available: MoneyValue?
    let daily: PeriodicLimit?
    let monthly: PeriodicLimit?
    let yearly: PeriodicLimit?
}

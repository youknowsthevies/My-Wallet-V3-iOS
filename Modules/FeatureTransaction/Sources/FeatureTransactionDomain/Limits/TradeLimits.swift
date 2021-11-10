// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Represents limits associated with a specific brokerage trade type.
/// It does not include limits specific to the user.
///
/// This is meant to be used by the `TransactionLimitsRepositoryAPI` ONLY!
/// This IS NOT meant to be used by the `TransactionEngine`s to build a transaction. Use `TransactionLimitsServiceAPI` for that instead!
///
/// Use `TransactionLimits` to combine data from `TradeLimits` with `CrossBorderLimits` limits.
/// To fetch `TransactionLimits` for a specific transaction, use `TransactionLimitsServiceAPI`.
public struct TradeLimits {

    public let currency: CurrencyType
    public let minOrder: MoneyValue
    public let maxOrder: MoneyValue
    public let maxPossibleOrder: MoneyValue
    public let daily: TransactionLimit?
    public let weekly: TransactionLimit?
    public let annual: TransactionLimit?

    public var maxTradableToday: MoneyValue {
        daily?.available ?? maxPossibleOrder
    }

    public init(
        currency: CurrencyType,
        minOrder: MoneyValue,
        maxOrder: MoneyValue,
        maxPossibleOrder: MoneyValue,
        daily: TransactionLimit?,
        weekly: TransactionLimit?,
        annual: TransactionLimit?
    ) {
        self.currency = currency
        self.minOrder = minOrder
        self.maxOrder = maxOrder
        self.maxPossibleOrder = maxPossibleOrder
        self.daily = daily
        self.weekly = weekly
        self.annual = annual
    }
}

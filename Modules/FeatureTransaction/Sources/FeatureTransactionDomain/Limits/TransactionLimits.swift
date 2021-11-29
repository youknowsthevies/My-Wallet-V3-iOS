// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

/// Use this struct to fill transaction data in `TransactionEngine`s.
public struct TransactionLimits: Equatable {

    public let minimum: MoneyValue
    public let maximum: MoneyValue
    public let maximumDaily: MoneyValue
    public let maximumAnnual: MoneyValue
    public let effectiveLimit: EffectiveLimit
    public let suggestedUpgrade: SuggestedLimitsUpgrade?

    public init(
        minimum: MoneyValue,
        maximum: MoneyValue,
        maximumDaily: MoneyValue,
        maximumAnnual: MoneyValue,
        effectiveLimit: EffectiveLimit?,
        suggestedUpgrade: SuggestedLimitsUpgrade?
    ) {
        self.minimum = minimum
        self.maximum = maximum
        self.maximumDaily = maximumDaily
        self.maximumAnnual = maximumAnnual
        self.effectiveLimit = effectiveLimit ?? EffectiveLimit(timeframe: .single, value: maximum)
        self.suggestedUpgrade = suggestedUpgrade
    }
}

extension TransactionLimits {

    public static func zero(for currency: CurrencyType) -> TransactionLimits {
        fixedValue(.zero(currency: currency))
    }

    public static func noLimits(for currency: CurrencyType) -> TransactionLimits {
        // NOTE: This should really use `nil` for all values.
        // Not done so because of required refactoring in TxFlow and lack of time.
        fixedValue(MoneyValue.decimalMaximum(for: currency))
    }

    private static func fixedValue(_ fixedValue: MoneyValue) -> TransactionLimits {
        TransactionLimits(
            minimum: fixedValue,
            maximum: fixedValue,
            maximumDaily: fixedValue,
            maximumAnnual: fixedValue,
            effectiveLimit: .init(timeframe: .single, value: fixedValue),
            suggestedUpgrade: nil
        )
    }
}

// MARK: - Currency Conversion

extension TransactionLimits {

    public func convert(using exchangeRate: MoneyValue) -> TransactionLimits {
        TransactionLimits(
            minimum: minimum.convert(using: exchangeRate),
            maximum: maximum.convert(using: exchangeRate),
            maximumDaily: maximumDaily.convert(using: exchangeRate),
            maximumAnnual: maximumAnnual.convert(using: exchangeRate),
            effectiveLimit: effectiveLimit,
            suggestedUpgrade: suggestedUpgrade
        )
    }
}

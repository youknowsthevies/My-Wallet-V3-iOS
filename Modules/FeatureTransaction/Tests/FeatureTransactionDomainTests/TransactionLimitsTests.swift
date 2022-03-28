@testable import FeatureTransactionDomain
import MoneyKit
import XCTest

class TransactionLimitsTests: XCTestCase {

    func test_convertLimits_same_currency() throws {
        let startingLimit = TransactionLimits(
            currencyType: .fiat(.USD),
            minimum: MoneyValue(amount: 5_00, currency: .fiat(.USD)),
            maximum: MoneyValue(amount: 1_000_00, currency: .fiat(.USD)),
            maximumDaily: MoneyValue(amount: 10_000_00, currency: .fiat(.USD)),
            maximumAnnual: MoneyValue(amount: 100_000_00, currency: .fiat(.USD)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue(amount: 1_000_00, currency: .fiat(.USD))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .tier2,
                available: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                daily: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                )
            )
        )
        let convertedLimit = startingLimit.convert(using: .one(currency: .fiat(.USD)))
        XCTAssertEqual(startingLimit, convertedLimit)
    }

    func test_convertLimits_different_currencies() throws {
        let startingLimit = TransactionLimits(
            currencyType: .fiat(.USD),
            minimum: MoneyValue(amount: 5_00, currency: .fiat(.USD)),
            maximum: MoneyValue(amount: 1_000_00, currency: .fiat(.USD)),
            maximumDaily: MoneyValue(amount: 10_000_00, currency: .fiat(.USD)),
            maximumAnnual: MoneyValue(amount: 100_000_00, currency: .fiat(.USD)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue(amount: 1_000_00, currency: .fiat(.USD))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .tier2,
                available: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                daily: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue(amount: 1_000_000_00, currency: .fiat(.USD)),
                    effective: false
                )
            )
        )
        let expectedLimit = TransactionLimits(
            currencyType: .fiat(.GBP),
            minimum: MoneyValue(amount: 10_00, currency: .fiat(.GBP)),
            maximum: MoneyValue(amount: 2_000_00, currency: .fiat(.GBP)),
            maximumDaily: MoneyValue(amount: 20_000_00, currency: .fiat(.GBP)),
            maximumAnnual: MoneyValue(amount: 200_000_00, currency: .fiat(.GBP)),
            effectiveLimit: EffectiveLimit(
                timeframe: .daily,
                value: MoneyValue(amount: 2_000_00, currency: .fiat(.GBP))
            ),
            suggestedUpgrade: SuggestedLimitsUpgrade(
                requiredTier: .tier2,
                available: MoneyValue(amount: 2_000_000_00, currency: .fiat(.GBP)),
                daily: PeriodicLimit(
                    limit: MoneyValue(amount: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                ),
                monthly: PeriodicLimit(
                    limit: MoneyValue(amount: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                ),
                yearly: PeriodicLimit(
                    limit: MoneyValue(amount: 2_000_000_00, currency: .fiat(.GBP)),
                    effective: false
                )
            )
        )
        let convertedLimit = startingLimit.convert(using: MoneyValue(amount: 2_00, currency: .fiat(.GBP)))
        XCTAssertEqual(expectedLimit, convertedLimit)
    }
}

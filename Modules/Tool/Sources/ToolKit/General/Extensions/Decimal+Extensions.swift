// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Decimal {

    public var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    public func roundTo(places: Int, roundingMode: RoundingMode = .bankers) -> Decimal {
        let roundingBehaviour = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: Int16(places),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
        let rounded = (self as NSDecimalNumber)
            .rounding(accordingToBehavior: roundingBehaviour)
        return rounded as Decimal
    }

    /// Returns a string representation of the current value, in the user's current locale.
    ///
    /// - Parameters:
    ///   - decimalPrecision: A number of decimal places.
    ///   - locale:           A locale.
    public func string(with decimalPrecision: Int, locale: Locale = .current) -> String {
        String(format: "%.\(decimalPrecision)f", locale: locale, doubleValue)
    }
}

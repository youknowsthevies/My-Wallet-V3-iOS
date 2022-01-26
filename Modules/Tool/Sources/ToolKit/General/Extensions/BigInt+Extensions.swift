// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

extension BigInt {
    public static let one = BigInt(1)
    public static let zero = BigInt(0)
}

extension BigInt {
    public var decimal: Decimal {
        Decimal(string: String(self))!
    }
}

extension BigInt {

    /// Creates a big integer.
    ///
    /// - Parameter decimal: A decimal value. Any fractional places will be trimmed.
    public init(decimalLiteral decimal: Decimal) {
        self.init(stringLiteral: "\(decimal.roundTo(places: 0))")
    }

    /// Returns the quotient of dividing the current value by another.
    ///
    /// This method will round the last digit.
    ///
    /// - Parameter divisor: A value to divide by.
    public func divide(by divisor: Decimal) -> BigInt {
        var lhs = self
        var rhs = divisor
        if rhs.exponent < 0 {
            lhs *= BigInt(10).power(abs(rhs.exponent))
            rhs *= pow(10, abs(rhs.exponent))
        }

        let rhsBigInt = BigInt(decimalLiteral: rhs)
        let (quotient, remainder) = lhs.quotientAndRemainder(dividingBy: rhsBigInt)
        // Will round up when the divisior is not 1, and the divisor is less than double the remainder.
        // We double the remainder instead of halving the divisor in order to preserve precision.
        let shouldRoundUp = rhsBigInt > 1 && (remainder * 2) >= rhsBigInt
        return shouldRoundUp ? quotient + 1 : quotient
    }

    /// Returns the result of dividing the current value by another.
    ///
    /// This will incur a **precision loss** on the current value, but will preserve the decimal places of the division.
    ///
    /// - Parameter divisor: A value to divide by.
    public func decimalDivision(by divisor: BigInt) -> Decimal {
        let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
        return quotient.decimal
            + (remainder.decimal / divisor.decimal)
    }

    /// Returns a major value from the current (minor) value.
    ///
    /// - Warning: Converting to a major value will incur a **precision loss**, and thus it should only be used for displaying purposes.
    ///
    /// - Parameters:
    ///   - baseDecimalPlaces:     The number of decimal places.
    ///   - roundingDecimalPlaces: The number of decimal places to round to.
    ///   - roundingMode:          A rounding mode.
    public func toDecimalMajor(
        baseDecimalPlaces: Int,
        roundingDecimalPlaces: Int,
        roundingMode: Decimal.RoundingMode = .bankers
    ) -> Decimal {
        let divisor = BigInt(10).power(baseDecimalPlaces)
        let majorValue = decimalDivision(by: divisor)
        return majorValue.roundTo(places: roundingDecimalPlaces, roundingMode: roundingMode)
    }
}

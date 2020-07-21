//
//  BigInt+Extensions.swift
//  PlatformKit
//
//  Created by Jack on 29/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import Foundation

extension BigInt {
    public static let zero = BigInt(0)
}

extension BigUInt {
    public static let zero = BigUInt(0)
}

extension BigInt {
    public func decimalDivision(divisor: BigInt) -> Decimal {
        let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
        return Decimal(string: String(quotient))!
            + (Decimal(string: String(remainder))! / Decimal(string: String(divisor))!)
    }

    /// Assuming `self` is a minor value. Converting it to major.
    /// Note that doing so may cause the returned value to lose precision,
    /// therefore we should avoid using it for anything other than to display data.
    /// - Parameters:
    ///   - maxDecimalPlaces: maximum decimal places allowed
    /// - Returns: A major value (Decimal)
    public func toDisplayMajor(maxDecimalPlaces: Int) -> Decimal {
        let divisor = BigInt(10).power(maxDecimalPlaces)
        let majorValue = decimalDivision(divisor: divisor)
        return majorValue.roundTo(places: maxDecimalPlaces)
    }
    
    public func toMinor(maxDecimalPlaces: Int) -> BigInt {
        let minorDecimal = self * BigInt(10).power(maxDecimalPlaces)
        return minorDecimal
    }
}

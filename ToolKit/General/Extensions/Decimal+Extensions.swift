//
//  Decimal+Extensions.swift
//  ToolKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Decimal {
    public var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    public func roundTo(places: Int) -> Decimal {
        guard places >= 0 else {
            return self
        }

        let decimalInString = "\(self)"
        guard let peroidIndex = decimalInString.firstIndex(of: ".") else {
            return self
        }

        let startIndex = decimalInString.startIndex
        let maxIndex = decimalInString.endIndex

        if places == 0 {
            let roundedString = String(decimalInString[startIndex..<peroidIndex])
            return Decimal(string: roundedString) ?? self
        }

        guard let endIndex = decimalInString.index(peroidIndex, offsetBy: places+1, limitedBy: maxIndex) else {
            return self
        }
        let roundedString = String(decimalInString[startIndex..<endIndex])
        return Decimal(string: roundedString) ?? self
    }
}

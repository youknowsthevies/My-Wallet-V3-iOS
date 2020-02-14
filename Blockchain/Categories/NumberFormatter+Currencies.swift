//
//  NSNumberFormatter+Currencies.swift
//  Blockchain
//
//  Created by Paulo on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension String {
    /// "," = U+002C
    fileprivate static let comma = "\u{002C}"
    /// "." = U+002E
    fileprivate static let fullStop = "\u{002E}"
    /// "٫" = U+066B
    fileprivate static let arabicDecimalSeparator = "\u{066B}"
}
extension NumberFormatter {

     /// Parses a decimal String into a UInt64 satoshis value.
     /// - Parameter inputString: decimal string
     /// - Returns: UInt64 Satoshis representation of the value
    @objc class func parseBitcoinValue(from string: String?) -> UInt64 {
        // String should be not nil, nor empty
        guard let string = string, !string.isEmpty else { return 0 }
        // Convert value to a safe value
        let requestedAmountString = NumberFormatter.convert(decimalString: string)
        // Safe value should not be empty
        guard !requestedAmountString.isEmpty else { return 0 }
        return parseValueBitcoin(string)
    }

    /// Parses a full stop '.' delimitered decimal string into a UInt64 satoshis value.
    private class func parseValueBitcoin(_ string: String) -> UInt64 {
        // String should not be empty
        guard !string.isEmpty else { return 0 }

        var string = string
        // If starts with delimiter '.', adds a 0 integral part
        if string.hasPrefix(.fullStop) {
            string = "0" + string
        }

        // Split into integral and fractional parts separated by a full stop '.'
        let components = string.split(separator: ".")

        // Components should not be empty
        guard !components.isEmpty else { return 0 }

        // FractionalPart
        let hasFractionalPart: Bool = components.indices.contains(1)
        var fractionalPart: String = hasFractionalPart ? String(components[1]) : "0"
        // Suffix fractionalPart with '0' until it has length 8
        while fractionalPart.count < 8 {
            fractionalPart.append("0")
        }
        // Remove all leading 0s from fractionalPart
        while fractionalPart.hasPrefix("0") {
            fractionalPart = String(fractionalPart.dropFirst())
        }
        // Creates UInt64 from fractionalPart
        let fractionalPartUInt: UInt64 = UInt64(fractionalPart)!

        // IntegralPart
        let integralPart: String = String(components[0])
        // Creates UInt64 from integralPart
        let integralPartUInt: UInt64 = UInt64(integralPart)!

        // IntegralPart in satoshis is IntegralPart multiplied by Satoshi base (1e8)
        let integralPartSatoshisUInt: UInt64 = integralPartUInt * UInt64(1e8)

        // Result is IntegralPart in satoshis plus FractionalPart
        let result: UInt64 = integralPartSatoshisUInt + fractionalPartUInt

        return result
    }

    /// A dictionary mapping a Unicode Arabic-Indic Digit key to a Unicode Digit value.
    fileprivate static let arabicIndicDigitToDigitMap: [String: String] = [
        "\u{0660}": "0",
        "\u{0661}": "1",
        "\u{0662}": "2",
        "\u{0663}": "3",
        "\u{0664}": "4",
        "\u{0665}": "5",
        "\u{0666}": "6",
        "\u{0667}": "7",
        "\u{0668}": "8",
        "\u{0669}": "9",
        .arabicDecimalSeparator: .fullStop
    ]

    /// - Returns: String by replacing occurrences of Arabic-Indic Unicode Digits with regular Unicode Digits
    fileprivate class func replaceArabicIndicUnicodeIndicDigitsWithUnicodeDigits(from value: String) -> String {
        return arabicIndicDigitToDigitMap
            .reduce(value) { (result, tuple) -> String in
                return result.replacingOccurrences(of: tuple.key, with: tuple.value)
        }
    }

    /// Removes a arabic decimal separator (Unicode U+066B) if it is present.
    /// Else, replaces a comma (Unicode U+002C) with a full stop (Unicode U+002E)
    /// - Returns: 'Safe' string with full stop '.' delimiter.
    @objc class func convert(decimalString value: String?) -> String {
        guard let value = value, !value.isEmpty else { return "" }

        if value.contains(String.arabicDecimalSeparator) {
            return replaceArabicIndicUnicodeIndicDigitsWithUnicodeDigits(from: value)
        } else {
            return value.replacingOccurrences(of: String.comma, with: String.fullStop)
        }
    }
}

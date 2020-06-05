//
//  CryptoValue+Money.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// MARK: - Money

extension CryptoValue: Money {

    /// The currency code for the money (e.g. "USD", "BTC", etc.)
    public var code: String {
        currencyType.code
    }

    public var displayCode: String {
        currencyType.displayCode
    }

    public var isZero: Bool {
        amount.isZero
    }

    public var isPositive: Bool {
        amount > 0
    }

    /// The maximum number of decimal places supported by the money
    public var maxDecimalPlaces: Int {
        currencyType.maxDecimalPlaces
    }

    /// The maximum number of displayable decimal places.
    public var maxDisplayableDecimalPlaces: Int {
        currencyType.maxDisplayableDecimalPlaces
    }

    /// Converts this money to a displayable String in its major format
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Returns: the displayable String
    public func toDisplayString(includeSymbol: Bool, locale: Locale = Locale.current) -> String {
        let formatter = CryptoFormatterProvider.shared.formatter(locale: locale, cryptoCurrency: currencyType)
        return formatter.format(value: self, withPrecision: .short, includeSymbol: includeSymbol)
    }
}

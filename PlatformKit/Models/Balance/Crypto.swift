//
//  Crypto.swift
//  PlatformKit
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public protocol Crypto: Money {
    var currencyType: CryptoCurrency { get }

    /// The amount is the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    var amount: BigInt { get }
    var value: CryptoValue { get }
}

extension Crypto {
    public var currencyCode: String {
        return value.currencyCode
    }

    public var isZero: Bool {
        return value.isZero
    }

    public var isPositive: Bool {
        return value.isPositive
    }

    public var symbol: String {
        return value.symbol
    }

    public var maxDecimalPlaces: Int {
        return value.maxDecimalPlaces
    }

    public var maxDisplayableDecimalPlaces: Int {
        return value.maxDisplayableDecimalPlaces
    }

    public var currencyType: CryptoCurrency {
        return value.currencyType
    }

    public var amount: BigInt {
        return value.amount
    }

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        return value.toDisplayString(includeSymbol: includeSymbol, locale: locale)
    }
}

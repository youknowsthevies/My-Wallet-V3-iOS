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
    
    public var code: String {
        currencyType.code
    }
    
    public var displayCode: String {
        currencyType.displayCode
    }
    
    public var currencyType: CryptoCurrency {
        value.currencyType
    }

    public var isZero: Bool {
        value.isZero
    }

    public var isPositive: Bool {
        value.isPositive
    }

    public var maxDecimalPlaces: Int {
        value.maxDecimalPlaces
    }

    public var maxDisplayableDecimalPlaces: Int {
        value.maxDisplayableDecimalPlaces
    }

    public var amount: BigInt {
        value.amount
    }

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        value.toDisplayString(includeSymbol: includeSymbol, locale: locale)
    }
}

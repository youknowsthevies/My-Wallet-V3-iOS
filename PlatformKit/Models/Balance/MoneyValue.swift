//
//  MoneyValue.swift
//  PlatformKit
//
//  Created by Jack Pooley on 24/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public enum MoneyValueError: Error {
    case invalidInput
    case invalidCryptoAmount
}

public struct MoneyValue: Money, Hashable, Equatable {
    
    private enum Value: Hashable, Equatable {
        case fiat(FiatValue)
        case crypto(CryptoValue)
        
        init(major amount: String, fiat fiatCurrency: FiatCurrency) throws {
            self = .fiat(FiatValue.create(amountString: amount, currency: fiatCurrency))
        }
        
        init(major amount: String, crypto cryptoCurrency: CryptoCurrency) throws {
            guard let cryptoValue = CryptoValue.createFromMajorValue(string: amount, assetType: cryptoCurrency) else {
                throw MoneyValueError.invalidCryptoAmount
            }
            self = .crypto(cryptoValue)
        }
        
        init(minor amount: String, fiat fiatCurrency: FiatCurrency) throws {
            self = .fiat(FiatValue(minor: amount, currency: fiatCurrency))
        }
        
        init(minor amount: String, crypto cryptoCurrency: CryptoCurrency) throws {
            guard let cryptoValue = CryptoValue.createFromMinorValue(amount, assetType: cryptoCurrency) else {
                throw MoneyValueError.invalidCryptoAmount
            }
            self = .crypto(cryptoValue)
        }
    }
    
    public var currencyType: CurrencyType {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.currency
        case .fiat(let fiatValue):
            return fiatValue.currency
        }
    }
    
    public var isCrypto: Bool {
        switch value {
        case .crypto:
            return true
        case .fiat:
            return false
        }
    }
    
    public var isFiat: Bool {
        !isCrypto
    }
    
    public var isZero: Bool {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.isZero
        case .fiat(let fiatValue):
            return fiatValue.isZero
        }
    }
    
    public var isPositive: Bool {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.isPositive
        case .fiat(let fiatValue):
            return fiatValue.isPositive
        }
    }
    
    public var maxDecimalPlaces: Int {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.maxDecimalPlaces
        case .fiat(let fiatValue):
            return fiatValue.maxDecimalPlaces
        }
    }
    
    public var maxDisplayableDecimalPlaces: Int {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.maxDisplayableDecimalPlaces
        case .fiat(let fiatValue):
            return fiatValue.maxDisplayableDecimalPlaces
        }
    }
    
    public var amount: BigInt {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.amount
        case .fiat(let fiatValue):
            return fiatValue.minorAmount
        }
    }
    
    public var majorValue: Decimal {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.majorValue
        case .fiat(let fiatValue):
            return fiatValue.majorValue
        }
    }
    
    private let value: Value
    
    public var fiatValue: FiatValue? {
        guard case Value.fiat(let value) = value else {
            return nil
        }
        return value
    }
    
    public var cryptoValue: CryptoValue? {
        guard case Value.crypto(let value) = value else {
            return nil
        }
        return value
    }
    
    /// Constructs a `MoneyValue`
    /// - Parameters:
    ///   - amount: the fiat or crypto amount in major units
    ///   - currency: the fiat or crypto currency
    /// - Throws: If the crypto of fiat currency is unknown or the amount is invalid this will throw
    public init(major amount: String, currency: String) throws {
        let currency = try CurrencyType(currency: currency)
        switch currency {
        case .crypto(let cryptoCurrency):
            self.value = try Value(major: amount, crypto: cryptoCurrency)
        case .fiat(let fiatCurrency):
            self.value = try Value(major: amount, fiat: fiatCurrency)
        }
    }
    
    /// Constructs a `MoneyValue`
    /// - Parameters:
    ///   - amount: the fiat or crypto amount in minor units
    ///   - currency: the fiat or crypto currency
    /// - Throws: If the crypto of fiat currency is unknown or the amount is invalid this will throw
    public init(minor amount: String, currency: String) throws {
        let currency = try CurrencyType(currency: currency)
        switch currency {
        case .crypto(let cryptoCurrency):
            self.value = try Value(minor: amount, crypto: cryptoCurrency)
        case .fiat(let fiatCurrency):
            self.value = try Value(minor: amount, fiat: fiatCurrency)
        }
    }
    
    /// Constructs a `MoneyValue`
    /// - Parameters:
    ///   - amount: the fiat or crypto amount in minor units
    ///   - currency: the fiat or crypto currency
    /// - Throws: If the crypto of fiat currency is unknown or the amount is invalid this will throw
    public init(minor amount: Int, currency: String) throws {
        try self.init(minor: "\(amount)", currency: currency)
    }
    
    /// Constructs a `MoneyValue`
    /// - Parameters:
    ///   - amount: the fiat or crypto amount in minor units
    ///   - currency: the fiat or crypto currency
    /// - Throws: If the crypto of fiat currency is unknown or the amount is invalid this will throw
    public init(minor amount: BigInt, currency: String) throws {
        try self.init(minor: "\(amount)", currency: currency)
    }
    
    public init(major amount: BigInt, currencyType: CurrencyType) throws {
        let amount = amount.toMinor(maxDecimalPlaces: currencyType.maxDecimalPlaces)
        try self.init(minor: "\(amount)", currency: currencyType.code)
    }
    
    public init(cryptoValue: CryptoValue) {
        self.value = .crypto(cryptoValue)
    }
    
    public init(fiatValue: FiatValue) {
        self.value = .fiat(fiatValue)
    }
    
    public func toDisplayString(includeSymbol: Bool, locale: Locale = .current) -> String {
        switch value {
        case .crypto(let cryptoValue):
            return cryptoValue.toDisplayString(includeSymbol: includeSymbol, locale: locale)
        case .fiat(let fiatValue):
            return fiatValue.toDisplayString(includeSymbol: includeSymbol, locale: locale)
        }
    }
    
    public func value(before percentageChange: Double) throws -> MoneyValue {
        switch value {
        case .fiat(let value):
            return MoneyValue(fiatValue: value.value(before: percentageChange))
        case .crypto(let value):
            return MoneyValue(cryptoValue: try value.value(before: percentageChange))
        }
    }
    
    public static func zero(_ cryptoCurrency: CryptoCurrency) -> MoneyValue {
        MoneyValue(cryptoValue: CryptoValue(currencyType: cryptoCurrency, amount: 0))
    }
    
    public static func zero(_ fiatCurrency: FiatCurrency) -> MoneyValue {
        MoneyValue(fiatValue: FiatValue(currencyCode: fiatCurrency.code, amount: 0))
    }
    
    public static func zero(_ currencyType: CurrencyType) -> MoneyValue {
        switch currencyType {
        case .fiat(let currency):
            return .zero(currency)
        case .crypto(let currency):
            return .zero(currency)
        }
    }
    
    public func convert(using exchangeRate: MoneyValue) throws -> MoneyValue {
        let exchangeRateAmount = exchangeRate.majorValue
        let majorDecimal = majorValue * exchangeRateAmount
        let major = "\(majorDecimal)"
        return try MoneyValue(major: major, currency: exchangeRate.currencyType.code)
    }
}

extension MoneyValue {
    static func from(major amount: String, currency: String) -> Result<MoneyValue, MoneyValueError> {
        Result { try MoneyValue(major: amount, currency: currency) }
            .mapError { _ in MoneyValueError.invalidInput }
    }
}

extension CryptoValue {
    public var moneyValue: MoneyValue {
        MoneyValue(cryptoValue: self)
    }
}

extension FiatValue {
    public var moneyValue: MoneyValue {
        MoneyValue(fiatValue: self)
    }
}

public struct MoneyValueComparisonError: Error {
    let currencyType1: CurrencyType
    let currencyType2: CurrencyType
}

// MARK: - Operators

extension MoneyValue {
    
    public static func max(_ lhs: MoneyValue, _ rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.max, FiatValue.max)
    }
    
    public static func min(_ lhs: MoneyValue, _ rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.min, FiatValue.min)
    }
    
    public static func + (lhs: MoneyValue, rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.add, FiatValue.add)
    }
    
    public static func - (lhs: MoneyValue, rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.subtract, FiatValue.subtract)
    }
    
    public static func * (lhs: MoneyValue, rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.multiply, FiatValue.multiply)
    }
    
    public static func / (lhs: MoneyValue, rhs: MoneyValue) throws -> MoneyValue {
        try apply(lhs, rhs, CryptoValue.divide, FiatValue.divide)
    }
    
    public static func > (lhs: MoneyValue, rhs: MoneyValue) throws -> Bool {
        try apply(lhs, rhs, CryptoValue.greaterThan, FiatValue.greaterThan)
    }
    
    public static func < (lhs: MoneyValue, rhs: MoneyValue) throws -> Bool {
        try apply(lhs, rhs, CryptoValue.lessThan, FiatValue.lessThan)
    }
    
    public static func >= (lhs: MoneyValue, rhs: MoneyValue) throws -> Bool {
        try apply(lhs, rhs, CryptoValue.greaterThanOrEqualTo, FiatValue.greaterThanOrEqualTo)
    }
    
    public static func <= (lhs: MoneyValue, rhs: MoneyValue) throws -> Bool {
        try apply(lhs, rhs, CryptoValue.lessThanOrEqualTo, FiatValue.lessThanOrEqualTo)
    }
    
    public static func += (lhs: inout MoneyValue, rhs: MoneyValue) throws {
        lhs = try lhs + rhs
    }
    
    public static func -= (lhs: inout MoneyValue, rhs: MoneyValue) throws {
        lhs = try lhs - rhs
    }
    
    public static func *= (lhs: inout MoneyValue, rhs: MoneyValue) throws {
        lhs = try lhs * rhs
    }
    
    private static func ensureComparable(value: MoneyValue, other: MoneyValue) throws {
        if value.currencyType != other.currencyType {
            throw MoneyValueComparisonError(currencyType1: value.currencyType, currencyType2: other.currencyType)
        }
    }
    
    private static func apply(
        _ lhs: MoneyValue,
        _ rhs: MoneyValue,
        _ cryptoOp: (CryptoValue, CryptoValue) throws -> CryptoValue,
        _ fiatOp: (FiatValue, FiatValue) throws -> FiatValue
    ) throws -> MoneyValue {
        try ensureComparable(value: lhs, other: rhs)
        switch (lhs.value, rhs.value) {
        case (.crypto(let lhsValue), .crypto(let rhsValue)):
            return (try cryptoOp(lhsValue, rhsValue)).moneyValue
        case (.fiat(let lhsValue), .fiat(let rhsValue)):
            return (try fiatOp(lhsValue, rhsValue)).moneyValue
        default:
            fatalError("This branch is unreachable")
        }
    }
    
    private static func apply(
        _ lhs: MoneyValue,
        _ rhs: MoneyValue,
        _ cryptoOp: (CryptoValue, CryptoValue) throws -> Bool,
        _ fiatOp: (FiatValue, FiatValue) throws -> Bool
    ) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        switch (lhs.value, rhs.value) {
        case (.crypto(let lhsValue), .crypto(let rhsValue)):
            return (try cryptoOp(lhsValue, rhsValue))
        case (.fiat(let lhsValue), .fiat(let rhsValue)):
            return (try fiatOp(lhsValue, rhsValue))
        default:
            fatalError("This branch is unreachable")
        }
    }
}

extension CryptoValue {
    
    fileprivate static func add(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try lhs + rhs
    }
    
    fileprivate static func subtract(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try lhs - rhs
    }
    
    fileprivate static func multiply(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try lhs * rhs
    }
    
    fileprivate static func divide(lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try lhs / rhs
    }
    
    fileprivate static func greaterThan(lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try lhs > rhs
    }
    
    fileprivate static func lessThan(lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try lhs < rhs
    }
    
    fileprivate static func greaterThanOrEqualTo(lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try lhs >= rhs
    }
    
    fileprivate static func lessThanOrEqualTo(lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try lhs <= rhs
    }
}

extension FiatValue {
    
    fileprivate static func add(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try lhs + rhs
    }
    
    fileprivate static func subtract(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try lhs - rhs
    }
    
    fileprivate static func multiply(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try lhs * rhs
    }
    
    fileprivate static func divide(lhs: FiatValue, rhs: FiatValue) throws -> FiatValue {
        try lhs / rhs
    }
    
    fileprivate static func greaterThan(lhs: FiatValue, rhs: FiatValue) throws -> Bool {
        try lhs > rhs
    }
    
    fileprivate static func lessThan(lhs: FiatValue, rhs: FiatValue) throws -> Bool {
        try lhs < rhs
    }
    
    fileprivate static func greaterThanOrEqualTo(lhs: FiatValue, rhs: FiatValue) throws -> Bool {
        try lhs >= rhs
    }
    
    fileprivate static func lessThanOrEqualTo(lhs: FiatValue, rhs: FiatValue) throws -> Bool {
        try lhs <= rhs
    }
}

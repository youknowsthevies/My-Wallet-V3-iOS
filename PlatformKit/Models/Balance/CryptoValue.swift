//
//  CryptoValue.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public struct CryptoComparisonError: Error {
    let currencyType1: CryptoCurrency
    let currencyType2: CryptoCurrency
}

public struct CryptoValue: Crypto {
    public let currencyType: CryptoCurrency
    
    /// The amount is the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt
    
    public var value: CryptoValue {
        return self
    }
    
    private init(currencyType: CryptoCurrency, amount: BigInt) {
        self.currencyType = currencyType
        self.amount = amount
    }
}

// MARK: - Money

extension CryptoValue: Money {
    
    /// The currency code for the money (e.g. "USD", "BTC", etc.)
    public var code: String {
        return currencyType.code
    }
    
    public var displayCode: String {
        return currencyType.displayCode
    }
    
    public var isZero: Bool {
        return amount.isZero
    }
    
    public var isPositive: Bool {
        return amount > 0
    }
    
    /// The maximum number of decimal places supported by the money
    public var maxDecimalPlaces: Int {
        return self.currencyType.maxDecimalPlaces
    }
    
    /// The maximum number of displayable decimal places.
    public var maxDisplayableDecimalPlaces: Int {
        return self.currencyType.maxDisplayableDecimalPlaces
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

// MARK: - Operators

extension CryptoValue: Hashable, Equatable {
    
    private static func ensureComparable(value: CryptoValue, other: CryptoValue) throws {
        if value.currencyType != other.currencyType {
            throw CryptoComparisonError(currencyType1: value.currencyType, currencyType2: other.currencyType)
        }
    }
    
    public static func max(_ x: CryptoValue, _ y: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: x, other: y)
        return try x > y ? x : y
    }
    
    public static func min(_ x: CryptoValue, _ y: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: x, other: y)
        return try x < y ? x : y
    }
    
    public static func + (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount + rhs.amount)
    }
    
    public static func - (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount - rhs.amount)
    }
    
    public static func * (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount * rhs.amount)
    }
    
    public static func / (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount / rhs.amount)
    }
    
    public static func > (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount > rhs.amount
    }
    
    public static func < (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount < rhs.amount
    }
    
    public static func >= (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount >= rhs.amount
    }
    
    public static func <= (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount <= rhs.amount
    }
    
    public static func += (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs + rhs
    }
    
    public static func -= (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs - rhs
    }
    
    public static func *= (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs * rhs
    }
    
    /// Calculates the value of `self` before a given percentage change
    public func value(before percentageChange: Double) throws -> CryptoValue {
        let percentage = CryptoValue.createFromMajorValue(
            string: "\(percentageChange + 1)",
            assetType: currencyType
        )!
        guard !percentage.isZero else {
            return .zero(assetType: currencyType)
        }
        return try self / percentage
    }
}

// MARK: - Shared

extension CryptoValue {
    /// The major value of the crypto (e.g. BTC, ETH, etc.)
    public var majorValue: Decimal {
        let divisor = BigInt(10).power(currencyType.maxDecimalPlaces)
        let majorValue = amount.decimalDivision(divisor: divisor)
        return majorValue.roundTo(places: currencyType.maxDecimalPlaces)
    }
    
    public static func zero(assetType: CryptoCurrency) -> CryptoValue {
        return CryptoValue(currencyType: assetType, amount: 0)
    }

    public static func createFromMinorValue(_ value: String, assetType: CryptoCurrency) -> CryptoValue? {
        guard let valueInBigInt = BigInt(value) else {
            return nil
        }
        return CryptoValue(currencyType: assetType, amount: valueInBigInt)
    }
    
    public static func createFromMinorValue(_ value: BigInt, assetType: CryptoCurrency) -> CryptoValue {
        return CryptoValue(currencyType: assetType, amount: value)
    }

    public static func createFromMajorValue(string value: String,
                                            assetType: CryptoCurrency,
                                            locale: Locale = Locale.current) -> CryptoValue? {
        guard let valueDecimal = Decimal(string: value, locale: locale) else {
            return nil
        }
        let minorDecimal = valueDecimal * pow(10, assetType.maxDecimalPlaces)
        return CryptoValue(currencyType: assetType, amount: BigInt(stringLiteral: "\(minorDecimal.roundTo(places: 0))"))
    }

    public func convertToFiatValue(exchangeRate: FiatValue) -> FiatValue {
        let conversionAmount = majorValue * exchangeRate.amount
        return FiatValue.create(amount: conversionAmount, currency: exchangeRate.currency)
    }
}

// MARK: - Bitcoin

extension CryptoValue {
    public static var bitcoinZero: CryptoValue {
        return zero(assetType: .bitcoin)
    }
    
    public static func bitcoinFromSatoshis(bigInt satoshis: BigInt) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoin, amount: satoshis)
    }

    public static func bitcoinFromSatoshis(int satoshis: Int) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoin, amount: BigInt(satoshis))
    }
}

// MARK: - Ethereum

extension CryptoValue {
    public static var etherZero: CryptoValue {
        return zero(assetType: .ethereum)
    }
    
    public static func etherFromWei(string wei: String) -> CryptoValue? {
        return createFromMinorValue(wei, assetType: .ethereum)
    }
    
    public static func etherFromGwei(string gwei: String) -> CryptoValue? {
        guard let gweiInBigInt = BigInt(gwei) else {
            return nil
        }
        let weiInBigInt = gweiInBigInt * BigInt(1_000_000_000)
        return CryptoValue(currencyType: .ethereum, amount: weiInBigInt)
    }

    public static func etherFromMajor(string ether: String, locale: Locale = Locale.current) -> CryptoValue? {
        return createFromMajorValue(string: ether, assetType: .ethereum, locale: locale)
    }
}

// MARK: - Bitcoin Cash

extension CryptoValue {
    public static var bitcoinCashZero: CryptoValue {
        return zero(assetType: .bitcoinCash)
    }
    
    public static func bitcoinCashFromSatoshis(string satoshis: String) -> CryptoValue? {
        return createFromMinorValue(satoshis, assetType: .bitcoinCash)
    }

    public static func bitcoinCashFromSatoshis(int satoshis: Int) -> CryptoValue {
        return CryptoValue(currencyType: .bitcoinCash, amount: BigInt(satoshis))
    }
}

// MARK: - Stellar

extension CryptoValue {
    public static var lumensZero: CryptoValue {
        return zero(assetType: .stellar)
    }
    
    public static func lumensFromStroops(int stroops: Int) -> CryptoValue {
        return CryptoValue(currencyType: .stellar, amount: BigInt(stroops))
    }

    public static func lumensFromStroops(string stroops: String) -> CryptoValue? {
        guard let stroopsInBigInt = BigInt(stroops) else {
            return nil
        }
        return CryptoValue(currencyType: .stellar, amount: stroopsInBigInt)
    }

    public static func lumensFromMajor(int lumens: Int) -> CryptoValue {
        return createFromMajorValue(string: "\(lumens)", assetType: .stellar)!
    }

    public static func lumensFromMajor(string lumens: String) -> CryptoValue? {
        return createFromMajorValue(string: lumens, assetType: .stellar)
    }
}

// MARK: - PAX

extension CryptoValue {
    public static var paxZero: CryptoValue {
        return zero(assetType: .pax)
    }
    
    public static func paxFromMajor(string pax: String) -> CryptoValue? {
        return createFromMajorValue(string: pax, assetType: .pax)
    }
}

// MARK: - Number Extensions

extension BigInt {
    func decimalDivision(divisor: BigInt) -> Decimal {
        let (quotient, remainder) =  quotientAndRemainder(dividingBy: divisor)
        return Decimal(string: String(quotient))!
            + (Decimal(string: String(remainder))! / Decimal(string: String(divisor))!)
    }
}

extension Decimal {
    public var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }

    func roundTo(places: Int) -> Decimal {
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

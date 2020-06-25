//
//  CryptoValue.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

public struct CryptoValue: Crypto, Hashable, Equatable {
    public let currencyType: CryptoCurrency
    
    /// The amount is the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt
    
    public var value: CryptoValue {
        self
    }
    
    init(currencyType: CryptoCurrency, amount: BigInt) {
        self.currencyType = currencyType
        self.amount = amount
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
        CryptoValue(currencyType: assetType, amount: 0)
    }

    public init?(minor: String, cryptoCurreny: CryptoCurrency) {
        guard let value = BigInt(minor) else {
            return nil
        }
        self.init(currencyType: cryptoCurreny, amount: value)
    }
    
    public static func createFromMinorValue(_ value: String, assetType: CryptoCurrency) -> CryptoValue? {
        guard let valueInBigInt = BigInt(value) else {
            return nil
        }
        return CryptoValue(currencyType: assetType, amount: valueInBigInt)
    }
    
    public static func createFromMinorValue(_ value: BigInt, assetType: CryptoCurrency) -> CryptoValue {
        CryptoValue(currencyType: assetType, amount: value)
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

// MARK: - Number Extensions

extension BigInt {
    public func decimalDivision(divisor: BigInt) -> Decimal {
        let (quotient, remainder) =  quotientAndRemainder(dividingBy: divisor)
        return Decimal(string: String(quotient))!
            + (Decimal(string: String(remainder))! / Decimal(string: String(divisor))!)
    }
}

extension Decimal {
    public var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
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

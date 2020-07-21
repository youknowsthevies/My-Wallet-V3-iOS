//
//  CryptoValue.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ToolKit

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
        amount.toDisplayMajor(maxDecimalPlaces: currencyType.maxDecimalPlaces)
    }
    
    public static func zero(currency: CryptoCurrency) -> CryptoValue {
        CryptoValue(currencyType: currency, amount: 0)
    }

    public init?(minor: String, cryptoCurrency: CryptoCurrency) {
        guard let value = BigInt(minor) else {
            return nil
        }
        self.init(currencyType: cryptoCurrency, amount: value)
    }
    
    public init?(major: String, cryptoCurrency: CryptoCurrency) {
        guard let value = Self.createFromMajorValue(string: major, assetType: cryptoCurrency) else {
            return nil
        }
        self = value
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
        return FiatValue.create(amount: conversionAmount, currency: exchangeRate.currencyType)
    }
}

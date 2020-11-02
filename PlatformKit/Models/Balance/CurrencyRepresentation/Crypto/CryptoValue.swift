//
//  CryptoValue.swift
//  Blockchain
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ToolKit

public struct CryptoValue: CryptoMoney, Hashable {
    
    /// The amount in the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt
    
    /// The crypto currency
    public let currencyType: CryptoCurrency
    
    public var value: CryptoValue {
        self
    }
    
    public init(amount: BigInt, currency: CryptoCurrency) {
        self.amount = amount
        self.currencyType = currency
    }
}

extension CryptoValue: MoneyOperating {}

extension CryptoValue {

    public func convertToFiatValue(exchangeRate: FiatValue) -> FiatValue {
        let conversionAmount = displayMajorValue * exchangeRate.displayMajorValue
        return FiatValue.create(major: conversionAmount, currency: exchangeRate.currencyType)
    }
}

extension CryptoValue {

    /// Calculates the value of `self` before a given percentage change
    public func value(before percentageChange: Double) throws -> CryptoValue {
        let percentageChange = percentageChange + 1
        guard percentageChange != 0 else {
            return .zero(currency: currencyType)
        }
        let majorAmount = displayMajorValue / Decimal(percentageChange)
        return CryptoValue.create(major: "\(majorAmount)", currency: currencyType)!
    }
}

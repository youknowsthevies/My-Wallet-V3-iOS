//
//  CustodialSingleAccountBalance.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public enum CustodialSingleAccountBalanceError: Error {
    case invalidInput
    case invalidFiatAmount
    case invalidCryptoAmount
}

public struct CustodialAccountBalance: CustodialAccountBalanceType, Equatable {
    
    private enum Value: Equatable {
        case fiat(FiatCustodialAccountBalance)
        case crypto(CryptoCustodialAccountBalance)
        
        init(minor amount: String,
             fiat fiatCurrency: FiatCurrency,
             withdrawable: String,
             pending: String) {
            let zero: FiatValue = .zero(currency: fiatCurrency)
            let available = FiatValue.create(minor: amount, currency: fiatCurrency)
            let withdrawable = FiatValue.create(minor: withdrawable, currency: fiatCurrency)
            let pending = FiatValue.create(minor: pending, currency: fiatCurrency)
            self = .fiat(
                .init(
                    available: available ?? zero,
                    withdrawable: withdrawable ?? zero,
                    pending: pending ?? zero
                )
            )
        }
        
        init(major amount: String,
             fiat fiatCurrency: FiatCurrency,
             withdrawable: String,
             pending: String) {
            let zero: FiatValue = .zero(currency: fiatCurrency)
            let available = FiatValue.create(major: amount, currency: fiatCurrency)
            let withdrawable = FiatValue.create(major: withdrawable, currency: fiatCurrency)
            let pending = FiatValue.create(major: pending, currency: fiatCurrency)
            self = .fiat(
                .init(
                    available: available ?? zero,
                    withdrawable: withdrawable ?? zero,
                    pending: pending ?? zero
                )
            )
        }
        
        init(minor amount: String,
             crypto cryptoCurrency: CryptoCurrency,
             withdrawable: String,
             pending: String) {
            let zero: CryptoValue = .zero(currency: cryptoCurrency)
            let available = CryptoValue.create(minor: amount, currency: cryptoCurrency)
            let withdrawable = CryptoValue.create(minor: withdrawable, currency: cryptoCurrency)
            let pending = CryptoValue.create(minor: pending, currency: cryptoCurrency)
            self = .crypto(
                .init(
                    available: available ?? zero,
                    withdrawable: withdrawable ?? zero,
                    pending: pending ?? zero
                )
            )
        }
        
        init(major amount: String,
             crypto cryptoCurrency: CryptoCurrency,
             withdrawable: String,
             pending: String) {
            let zero: CryptoValue = .zero(currency: cryptoCurrency)
            let available = CryptoValue.create(major: amount, currency: cryptoCurrency)
            let withdrawable = CryptoValue.create(major: withdrawable, currency: cryptoCurrency)
            let pending = CryptoValue.create(major: pending, currency: cryptoCurrency)
            self = .crypto(
                .init(
                    available: available ?? zero,
                    withdrawable: withdrawable ?? zero,
                    pending: pending ?? zero
                )
            )
        }
    }

    public var available: MoneyValue {
        switch self._value {
        case .crypto(let balance):
            return balance.available
        case .fiat(let balance):
            return balance.available
        }
    }
    
    public var withdrawable: MoneyValue {
        switch self._value {
        case .crypto(let balance):
            return balance.withdrawable
        case .fiat(let balance):
            return balance.withdrawable
        }
    }
    
    public var pending: MoneyValue {
        switch self._value {
        case .crypto(let balance):
            return balance.pending
        case .fiat(let balance):
            return balance.pending
        }
    }
    
    private let _value: Value
    
    init(currency: CurrencyType, response: CustodialBalanceResponse.Balance) {
        switch currency {
        case .crypto(let currencyType):
            self._value = .init(minor: response.available, crypto: currencyType, withdrawable: response.withdrawable, pending: response.pending)
        case .fiat(let currencyType):
            self._value = .init(
                minor: response.available,
                fiat: currencyType,
                withdrawable: response.withdrawable,
                pending: response.pending
            )
        }
    }
    
    public init(minorValue available: String,
                currencyType: CurrencyType,
                withdrawable: String = "0",
                pending: String = "0") {
        switch currencyType {
        case .crypto(let currency):
            self._value = .init(
                minor: available,
                crypto: currency,
                withdrawable: withdrawable,
                pending: pending
            )
        case .fiat(let currency):
            self._value = .init(
                minor: available,
                fiat: currency,
                withdrawable: withdrawable,
                pending: pending
            )
        }
    }
    
    public init(majorValue available: String,
                currencyType: CurrencyType,
                withdrawable: String = "0",
                pending: String = "0") {
        switch currencyType {
        case .crypto(let currency):
            self._value = .init(
                major: available,
                crypto: currency,
                withdrawable: withdrawable,
                pending: pending
            )
        case .fiat(let currency):
            self._value = .init(
                major: available,
                fiat: currency,
                withdrawable: withdrawable,
                pending: pending
            )
        }
    }
    
    public var currency: CurrencyType {
        available.currencyType
    }
    
    public var symbol: String {
        available.currencyType.symbol
    }
}

public extension CustodialAccountBalance {
    static func zero(currencyType: CurrencyType) -> CustodialAccountBalance {
        .init(currency: currencyType, response: .zero)
    }
}

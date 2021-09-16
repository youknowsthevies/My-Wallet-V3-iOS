// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A crypto money.
public protocol CryptoMoney: Money {

    /// The crypto currency.
    var currencyType: CryptoCurrency { get }

    /// The current crypto currency value represented as a `CryptoValue`.
    var value: CryptoValue { get }
}

extension CryptoMoney {

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        CryptoFormatterProvider.shared
            .formatter(locale: locale, cryptoCurrency: currencyType)
            .format(value: value, withPrecision: .short, includeSymbol: includeSymbol)
    }
}

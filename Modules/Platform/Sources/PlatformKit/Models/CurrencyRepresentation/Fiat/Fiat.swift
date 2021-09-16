// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A fiat money.
public protocol Fiat: Money {

    /// The fiat currency.
    var currencyType: FiatCurrency { get }

    /// The current fiat currency value represented as a `FiatValue`.
    var value: FiatValue { get }
}

extension Fiat {

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        toDisplayString(includeSymbol: includeSymbol, format: .fullLength, locale: locale)
    }

    /// Creates a displayable string, representing the currency amount in major units, in the given locale, using the given format, optionally including the currency symbol.
    ///
    /// - Parameters:
    ///   - includeSymbol: Whether the symbol should be included.
    ///   - format                    A format.
    ///   - locale:        A locale.
    public func toDisplayString(includeSymbol: Bool, format: NumberFormatter.CurrencyFormat, locale: Locale) -> String {
        let maxFractionDigits: Int
        switch format {
        case .fullLength:
            maxFractionDigits = currency.precision
        case .shortened where displayMajorValue.exponent < 0:
            // Has a fractional part only when the exponent is negative.
            maxFractionDigits = currency.precision
        case .shortened:
            maxFractionDigits = 0
        }

        return FiatFormatterProvider.shared
            .formatter(locale: locale, fiatValue: value, maxFractionDigits: maxFractionDigits)
            .format(amount: displayMajorValue, includeSymbol: includeSymbol)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/*
 let currency = FiatCurrency(rawValue: symbol)
 let fiat = FiatValue.create(minor: amount, currency: currency)
 */

public protocol FiatCurrencyFormatter {
    func displayString(amountMinor: String, currency: String) -> String?
}

public struct NoFormatFiatCurrencyFormatter: FiatCurrencyFormatter {
    public init() {}
    public func displayString(amountMinor: String, currency: String) -> String? {
        "\(currency) \(amountMinor)"
    }
}

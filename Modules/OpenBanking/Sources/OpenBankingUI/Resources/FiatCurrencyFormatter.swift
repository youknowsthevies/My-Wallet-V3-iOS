// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/*
 guard let currency = FiatCurrency(rawValue: symbol),
       let fiat = FiatValue.create(minor: amount, currency: currency)
 else {
     return .errorMessage(R.Bank.Payment.error.interpolating(symbol))
 }
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

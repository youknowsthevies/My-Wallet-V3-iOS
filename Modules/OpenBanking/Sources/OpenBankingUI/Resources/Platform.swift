import Foundation

@_spi(OpenBankingSetup) public var resources: Bundle = .main

/*
 guard let currency = FiatCurrency(rawValue: payment.amount.symbol),
       let fiat = FiatValue.create(minor: payment.amount.value, currency: currency)
 else {
     return .errorMessage(R.Bank.Payment.error.interpolating(payment.amount.symbol))
 }
 */


public protocol FiatCurrencyFormatter {
    func displayString(amountMinor: String, currency: String) -> String?
}

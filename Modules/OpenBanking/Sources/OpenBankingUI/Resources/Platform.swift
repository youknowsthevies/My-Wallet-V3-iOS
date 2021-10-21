import Foundation

@_spi(OpenBankingSetup) public var resources: Bundle = .main
@_spi(OpenBankingSetup) public var formatMoney: (_ amountMinor: String, _ currency: String) -> String? = { "\($1) \($0)" }

/*
 guard let currency = FiatCurrency(rawValue: payment.amount.symbol),
       let fiat = FiatValue.create(minor: payment.amount.value, currency: currency)
 else {
     return .errorMessage(R.Bank.Payment.error.interpolating(payment.amount.symbol))
 }
 */

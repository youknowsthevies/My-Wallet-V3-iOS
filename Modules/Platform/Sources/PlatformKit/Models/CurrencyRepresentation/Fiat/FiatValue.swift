// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// A fiat money value.
public struct FiatValue: Fiat, Hashable {

    public let amount: BigInt

    public let currencyType: FiatCurrency

    public var value: FiatValue {
        self
    }

    /// Creates a fiat value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A fiat currency.
    public init(amount: BigInt, currency: FiatCurrency) {
        self.amount = amount
        currencyType = currency
    }
}

extension FiatValue: MoneyOperating {}

extension FiatValue {

    // MARK: - Conversion

    /// Converts the current fiat value into a crypto value, using a given exchange rate from the crypto curency to the fiat currency.
    ///
    /// - Parameters:
    ///   - exchangeRate:   An exchange rate, representing one major unit of the crypto currency in the fiat currency.
    ///   - cryptoCurrency: A destination crypto currency.]
    public func convertToCryptoValue(exchangeRate: FiatValue, cryptoCurrency: CryptoCurrency) -> CryptoValue {
        guard !isZero, !exchangeRate.isZero else {
            return CryptoValue.zero(currency: cryptoCurrency)
        }
        let conversionAmount = displayMajorValue / exchangeRate.displayMajorValue
        return CryptoValue.create(major: conversionAmount, currency: cryptoCurrency)
    }
}

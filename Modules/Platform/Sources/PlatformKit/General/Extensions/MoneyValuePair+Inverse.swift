// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension MoneyValuePair {

    /// Returns the inversed money value pair.
    ///
    /// For a pair with base `1 BTC` and quote `50,000 USD`, this will return a pair with base `1 USD` and quote `1 / 50,000 BTC`.
    public var inverseQuote: MoneyValuePair {
        // `try`s are disabled here as this operation can never fail.
        // If it failed, it would be a developer error and thus it's better to crash.
        guard !base.isZero, !quote.isZero else {
            // swiftlint:disable:next force_try
            return try! MoneyValuePair(
                base: .zero(currency: quote.currency),
                exchangeRate: .zero(currency: base.currency)
            )
        }

        // swiftlint:disable:next force_try
        return try! MoneyValuePair(
            base: .one(currency: quote.currencyType),
            exchangeRate: base.convert(
                usingInverse: quote,
                currencyType: base.currencyType
            )
        )
    }
}

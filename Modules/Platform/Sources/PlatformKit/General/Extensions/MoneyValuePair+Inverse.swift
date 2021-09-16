// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension MoneyValuePair {

    /// Returns the inversed money value pair.
    ///
    /// For a pair with base `1 BTC` and quote `50,000 USD`, this will return a pair with base `1 USD` and quote `1 / 50,000 BTC`.
    public var inverseQuote: MoneyValuePair {
        guard !base.isZero, !quote.isZero else {
            return MoneyValuePair(
                base: .zero(currency: quote.currency),
                quote: .zero(currency: base.currency)
            )
        }

        return MoneyValuePair(
            base: .one(currency: quote.currencyType),
            quote: base.convert(usingInverse: quote, currencyType: base.currencyType)
        )
    }
}

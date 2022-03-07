// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

extension MoneyValuePair {

    /// Returns the inversed money value pair.
    ///
    /// For a pair with base `1 BTC` and quote `50,000 USD`, this will return a pair with base `1 USD` and quote `1 / 50,000 BTC`.
    public var inverseQuote: MoneyValuePair {
        guard !base.isZero, !quote.isZero else {
            return .zero(
                baseCurrency: quote.currency,
                quoteCurrency: base.currency
            )
        }

        let newBase: MoneyValue = .one(currency: quote.currency)
        // Convert base to quote currency first, and then perform conversion with inverse quote.
        let newQuote: MoneyValue = base
            .convert(using: newBase)
            .convert(usingInverse: quote, currency: base.currency)

        return MoneyValuePair(base: newBase, quote: newQuote)
    }
}

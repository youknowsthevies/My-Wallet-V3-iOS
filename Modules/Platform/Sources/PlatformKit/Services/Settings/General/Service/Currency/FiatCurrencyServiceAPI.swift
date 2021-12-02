// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

/// An API of a generic service which provides fiat currencies for display and trading.
public protocol FiatCurrencyServiceAPI: CurrencyServiceAPI {

    /// A publisher that streams `FiatCurrency` values
    var displayCurrencyPublisher: AnyPublisher<FiatCurrency, Never> { get }
}

extension FiatCurrencyServiceAPI {

    /// A publisher that completes after taking a single value from the `displayCurrencyPublisher` stream
    public var displayCurrency: AnyPublisher<FiatCurrency, Never> {
        displayCurrencyPublisher
            .first()
            .eraseToAnyPublisher()
    }

    public var currencyPublisher: AnyPublisher<Currency, Never> {
        displayCurrencyPublisher
            .map { $0 as Currency }
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

final class NoOpFiatCurrencyPublisher: FiatCurrencyPublisherAPI {
    var fiatCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        .just(.USD)
    }
}

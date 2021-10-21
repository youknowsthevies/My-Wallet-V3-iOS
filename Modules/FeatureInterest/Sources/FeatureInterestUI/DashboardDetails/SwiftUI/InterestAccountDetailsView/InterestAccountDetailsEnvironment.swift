// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import PlatformKit

struct InterestAccountDetailsEnvironment {
    let fiatCurrencyService: FiatCurrencyPublisherAPI
    let priceService: PriceServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension InterestAccountDetailsEnvironment {
    static let `default`: InterestAccountDetailsEnvironment = .init(
        fiatCurrencyService: resolve(),
        priceService: resolve(),
        mainQueue: .main
    )
}

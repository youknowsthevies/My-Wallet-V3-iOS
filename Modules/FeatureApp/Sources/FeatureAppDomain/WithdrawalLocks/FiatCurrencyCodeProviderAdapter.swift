// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureWithdrawalLocksDomain
import Foundation
import PlatformKit

final class FiatCurrencyCodeProviderAdapter: FiatCurrencyCodeProviderAPI {

    lazy var defaultFiatCurrencyCode: AnyPublisher<String, Never> = {
        fiatCurrencyPublisher.fiatCurrencyPublisher
            .map(\.code)
            .eraseToAnyPublisher()
    }()

    private let fiatCurrencyPublisher: FiatCurrencyPublisherAPI

    init(fiatCurrencyPublisher: FiatCurrencyPublisherAPI = resolve()) {
        self.fiatCurrencyPublisher = fiatCurrencyPublisher
    }
}

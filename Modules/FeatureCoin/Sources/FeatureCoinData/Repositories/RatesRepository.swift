// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import MoneyKit
import NetworkError

public struct RatesRepository: RatesRepositoryAPI {

    private let client: RatesClientAPI

    public init(_ client: RatesClientAPI) {
        self.client = client
    }

    public func fetchRate(
        code: String
    ) -> AnyPublisher<Double, NetworkError> {
        client.fetchInterestAccountRateForCurrencyCode(code)
            .map(\.rate)
            .eraseToAnyPublisher()
    }
}

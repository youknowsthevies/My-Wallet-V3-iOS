// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCoinDomain
import Foundation
import MoneyKit

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

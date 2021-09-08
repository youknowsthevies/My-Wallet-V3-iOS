// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureInterestDomain
import NabuNetworkError
import PlatformKit
import ToolKit

final class InterestAccountRateRepository: InterestAccountRateRepositoryAPI {

    // MARK: - Private Properties

    private let client: InterestAccountRateClientAPI

    // MARK: - Init

    init(
        client: InterestAccountRateClientAPI = resolve()
    ) {
        self.client = client
    }

    // MARK: - InterestAccountLimitsRepositoryAPI

    func fetchInteretAccountRateForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> AnyPublisher<InterestAccountRate, InterestAccountRateError> {
        client
            .fetchInterestAccountRateForCurrencyCode(currency.code)
            .mapError(InterestAccountRateError.networkError)
            .map(InterestAccountRate.init)
            .eraseToAnyPublisher()
    }
}

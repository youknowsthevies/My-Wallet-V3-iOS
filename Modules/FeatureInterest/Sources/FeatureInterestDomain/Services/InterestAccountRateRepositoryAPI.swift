// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError
import PlatformKit
public enum InterestAccountRateError: Error {
    case networkError(Error)
}

public protocol InterestAccountRateRepositoryAPI: AnyObject {

    /// Fetches the current `InterestAccountRate` for a given CryptoCurrency.
    /// - Parameter currency: CryptoCurrency
    func fetchInteretAccountRateForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> AnyPublisher<InterestAccountRate, InterestAccountRateError>
}

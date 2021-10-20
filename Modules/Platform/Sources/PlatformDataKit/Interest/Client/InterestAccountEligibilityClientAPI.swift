// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol InterestAccountEligibilityClientAPI: AnyObject {
    func fetchInterestAccountEligibilityResponse()
        -> AnyPublisher<InterestEligibilityResponse, NabuNetworkError>
}

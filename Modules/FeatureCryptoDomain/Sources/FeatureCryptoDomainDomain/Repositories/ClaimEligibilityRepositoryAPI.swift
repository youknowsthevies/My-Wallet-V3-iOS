// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

public protocol ClaimEligibilityRepositoryAPI {

    func checkClaimEligibility() -> AnyPublisher<Bool, Never>
}

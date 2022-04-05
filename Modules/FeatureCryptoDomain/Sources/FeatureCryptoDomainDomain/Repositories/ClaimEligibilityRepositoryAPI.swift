// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol ClaimEligibilityRepositoryAPI {

    func checkClaimEligibility() -> AnyPublisher<Bool, Never>
}

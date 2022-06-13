// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAuthenticationDomain
import Foundation

final class MockCheckReferralClient: CheckReferralClientAPI {
    var checkReferralCalled = false

    func checkReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        checkReferralCalled = true
        return .just(())
    }
}

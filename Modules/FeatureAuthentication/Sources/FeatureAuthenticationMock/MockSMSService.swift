// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockSMSService: SMSServiceAPI {

    func request(isResend: Bool) -> AnyPublisher<Void, SMSServiceError> {
        .just(())
    }
}

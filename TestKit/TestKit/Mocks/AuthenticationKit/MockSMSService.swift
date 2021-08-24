// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine

final class MockSMSService: SMSServiceAPI {

    func request() -> AnyPublisher<Void, SMSServiceError> {
        .just(())
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine

final class MockSMSService: SMSServiceAPI {

    func request(isResend: Bool) -> AnyPublisher<Void, SMSServiceError> {
        .just(())
    }
}

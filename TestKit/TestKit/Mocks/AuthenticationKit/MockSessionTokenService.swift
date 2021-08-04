// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine

final class MockSessionTokenService: SessionTokenServiceAPI {
    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        .just(())
    }
}

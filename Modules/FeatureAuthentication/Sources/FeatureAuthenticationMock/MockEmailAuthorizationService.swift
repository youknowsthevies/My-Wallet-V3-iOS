// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockEmailAuthorizationService: EmailAuthorizationServiceAPI {

    func cancel() {}

    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError> {
        .just(())
    }
}

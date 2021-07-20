// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine
import RxSwift

final class MockEmailAuthorizationService: EmailAuthorizationServiceAPI {

    var authorize: Completable = Completable.empty()

    func cancel() {}

    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError> {
        .just(())
    }
}

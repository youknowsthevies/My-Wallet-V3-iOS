// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine
import RxSwift

final class MockSessionTokenService: SessionTokenServiceAPI {

    func setupSessionToken() -> Completable {
        .empty()
    }

    func setupSessionTokenPublisher() -> AnyPublisher<Void, SessionTokenServiceError> {
        .just(())
    }
}

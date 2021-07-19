// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine
import RxSwift

final class MockSMSService: SMSServiceAPI {

    func request() -> Completable {
        .empty()
    }

    func requestPublisher() -> AnyPublisher<Void, SMSServiceError> {
        .just(())
    }
}

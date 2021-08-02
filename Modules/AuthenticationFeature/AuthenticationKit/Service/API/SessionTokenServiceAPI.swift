// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import RxSwift

public enum SessionTokenServiceError: Error {
    case networkError(NetworkError)
    case missingSessionToken
}

public protocol SessionTokenServiceCombineAPI: AnyObject {
    func setupSessionTokenPublisher() -> AnyPublisher<Void, SessionTokenServiceError>
}

public protocol SessionTokenServiceAPI: SessionTokenServiceCombineAPI {
    func setupSessionToken() -> Completable
}

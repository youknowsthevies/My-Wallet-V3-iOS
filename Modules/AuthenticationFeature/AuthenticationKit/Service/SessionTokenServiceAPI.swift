// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import NetworkKit

public enum SessionTokenServiceError: Error {
    case networkError(NetworkError)
    case missingToken
}

public protocol SessionTokenServiceCombineAPI: AnyObject {
    func setupSessionTokenPublisher() -> AnyPublisher<Void, SessionTokenServiceError>
}

public protocol SessionTokenServiceAPI: SessionTokenServiceCombineAPI {
    func setupSessionToken() -> Completable
}

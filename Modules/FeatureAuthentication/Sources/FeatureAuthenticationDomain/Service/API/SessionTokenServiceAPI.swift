// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError
import WalletPayloadKit

public enum SessionTokenServiceError: Error, Equatable {
    case networkError(NetworkError)
    case missingSessionToken
}

public protocol SessionTokenServiceAPI: AnyObject {
    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError>
}

public func sessionTokenServiceFactory(sessionRepository: SessionTokenRepositoryAPI) -> SessionTokenServiceAPI {
    SessionTokenService(sessionRepository: sessionRepository)
}

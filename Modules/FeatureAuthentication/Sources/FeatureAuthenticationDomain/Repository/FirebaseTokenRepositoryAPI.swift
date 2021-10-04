// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public enum PushNotificationsRepositoryError: Error {
    case networkError(NetworkError)
    case missingCredentials(MissingCredentialsError)
}

public protocol PushNotificationsRepositoryAPI {
    func revokeToken() -> AnyPublisher<Void, PushNotificationsRepositoryError>
}

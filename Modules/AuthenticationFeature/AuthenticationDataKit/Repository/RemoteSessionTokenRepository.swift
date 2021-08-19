// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import DIKit

final class RemoteSessionTokenRepository: RemoteSessionTokenRepositoryAPI {

    // MARK: - Properties

    var token: AnyPublisher<String?, SessionTokenServiceError> {
        apiClient
            .token
            .mapError(SessionTokenServiceError.networkError)
            .eraseToAnyPublisher()
    }

    private let apiClient: SessionTokenClientAPI

    // MARK: - Setup

    init(apiClient: SessionTokenClientAPI = resolve()) {
        self.apiClient = apiClient
    }
}

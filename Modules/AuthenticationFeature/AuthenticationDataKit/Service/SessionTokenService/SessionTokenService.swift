// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine

public final class SessionTokenService: SessionTokenServiceAPI {

    // MARK: - Injected

    private let client: SessionTokenClientAPI
    private let repository: SessionTokenRepositoryAPI

    // MARK: - Setup

    public init(client: SessionTokenClientAPI = SessionTokenClient(), repository: SessionTokenRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    public func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        repository.hasSessionTokenPublisher
            .flatMap { [client] hasSessionToken -> AnyPublisher<String?, SessionTokenServiceError> in
                guard !hasSessionToken else {
                    return .just("")
                }
                return client.token
                    .mapError(SessionTokenServiceError.networkError)
                    .eraseToAnyPublisher()
            }
            .flatMap { sessionTokenOrNil -> AnyPublisher<String, SessionTokenServiceError> in
                guard let sessionToken = sessionTokenOrNil else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [repository] sessionToken -> AnyPublisher<Void, SessionTokenServiceError> in
                repository.setPublisher(sessionToken: sessionToken)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}

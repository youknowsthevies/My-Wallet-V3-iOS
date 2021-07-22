// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public final class SessionTokenService: SessionTokenServiceAPI {

    // MARK: - Injected

    private let client: SessionTokenClientAPI
    private let repository: SessionTokenRepositoryAPI

    // MARK: - Setup

    public init(client: SessionTokenClientAPI = SessionTokenClient(), repository: SessionTokenRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    /// Requests a session token for the wallet, if not available already
    /// and assign it to the repository.
    public func setupSessionToken() -> Completable {
        repository.hasSessionToken
            .flatMapCompletable(weak: self) { (self, hasSessionToken) -> Completable in
                guard !hasSessionToken else {
                    return .empty()
                }
                return self.client.token
                    .flatMapCompletable(weak: self) { (self, sessionToken) -> Completable in
                        self.repository.set(sessionToken: sessionToken)
                    }
            }
    }
}

// MARK: - SessionTokenServiceCombineAPI

extension SessionTokenService {

    public func setupSessionTokenPublisher() -> AnyPublisher<Void, SessionTokenServiceError> {
        repository.hasSessionTokenPublisher
            .setFailureType(to: SessionTokenServiceError.self)
            .flatMap { [client] hasSessionToken -> AnyPublisher<String, SessionTokenServiceError> in
                guard !hasSessionToken else {
                    return .just("")
                }
                return client.tokenPublisher
            }
            .flatMap { [repository] sessionToken -> AnyPublisher<Void, SessionTokenServiceError> in
                repository.setPublisher(sessionToken: sessionToken)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}

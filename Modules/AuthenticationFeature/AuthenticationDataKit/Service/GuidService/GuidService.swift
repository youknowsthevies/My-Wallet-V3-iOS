// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public final class GuidService: GuidServiceAPI {

    // MARK: - Properties

    /// Fetches the `GUID`
    public var guid: Single<String> {
        sessionTokenRepository
            .sessionToken
            .flatMap(weak: self) { (self, token) -> Single<String> in
                guard let token = token else {
                    return .error(GuidServiceError.missingSessionToken)
                }
                return self.client.guid(by: token)
            }
    }

    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let client: GuidClientAPI

    // MARK: - Setup

    public init(sessionTokenRepository: SessionTokenRepositoryAPI, client: GuidClientAPI) {
        self.sessionTokenRepository = sessionTokenRepository
        self.client = client
    }
}

// MARK: GuidServiceCombineAPI

extension GuidService {

    public var guidPublisher: AnyPublisher<String, GuidServiceError> {
        sessionTokenRepository
            .sessionTokenPublisher
            .flatMap { [client] token -> AnyPublisher<String, GuidServiceError> in
                guard let token = token else {
                    return .failure(.missingSessionToken)
                }
                return client.guidPublisher(by: token)
                    .mapError(GuidServiceError.networkError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

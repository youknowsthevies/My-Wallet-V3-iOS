// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class GuidService: GuidServiceAPI {

    // MARK: - Types

    public enum FetchError: Error {
        case missingSessionToken
    }

    // MARK: - Properties

    /// Fetches the `GUID`
    public var guid: Single<String> {
        sessionTokenRepository
            .sessionToken
            .flatMap(weak: self) { (self, token) -> Single<String> in
                guard let token = token else {
                    return .error(FetchError.missingSessionToken)
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

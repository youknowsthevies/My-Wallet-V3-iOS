// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class JWTRepository: JWTRepositoryAPI {

    // MARK: - Properties

    private let client: JWTClientAPI

    // MARK: - Setup

    init(client: JWTClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - API

    func requestJWT(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, JWTServiceError> {
        client
            .requestJWT(guid: guid, sharedKey: sharedKey)
            .replaceError(with: .failedToRetrieveJWTToken)
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class RemoteGuidRepository: RemoteGuidRepositoryAPI {

    // MARK: - Properties

    private let apiClient: GuidClientAPI

    // MARK: - Setup

    init(apiClient: GuidClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func guid(token: String) -> AnyPublisher<String?, GuidServiceError> {
        apiClient
            .guid(by: token)
            .mapError(GuidServiceError.networkError)
            .eraseToAnyPublisher()
    }
}

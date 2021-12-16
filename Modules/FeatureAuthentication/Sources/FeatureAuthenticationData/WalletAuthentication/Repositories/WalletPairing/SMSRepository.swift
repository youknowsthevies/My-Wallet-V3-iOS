// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class SMSRepository: SMSRepositoryAPI {

    // MARK: - Properties

    private let apiClient: SMSClientAPI

    // MARK: - Setup

    init(
        apiClient: SMSClientAPI = resolve()
    ) {
        self.apiClient = apiClient
    }

    // MARK: - API

    func request(
        sessionToken: String,
        guid: String
    ) -> AnyPublisher<Void, SMSServiceError> {
        apiClient.requestOTP(
            sessionToken: sessionToken,
            guid: guid
        )
        .mapError(SMSServiceError.networkError)
        .eraseToAnyPublisher()
    }
}

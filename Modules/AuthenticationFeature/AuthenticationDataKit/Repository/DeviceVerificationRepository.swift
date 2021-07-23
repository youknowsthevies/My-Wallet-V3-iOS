// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import DIKit

final class DeviceVerificationRepository: DeviceVerificationRepositoryAPI {

    // MARK: - Properties

    private let apiClient: DeviceVerificationClientAPI

    // MARK: - Setup

    init(apiClient: DeviceVerificationClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - DeviceVerificationRepositoryAPI

    func sendDeviceVerificationEmail(
        to emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        apiClient
            .sendGuidReminder(emailAddress: emailAddress, captcha: captcha)
            .mapError(DeviceVerificationServiceError.networkError)
            .eraseToAnyPublisher()
    }

    func authorizeLogin(sessionToken: String, emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        apiClient
            .authorizeApprove(sessionToken: sessionToken, emailCode: emailCode)
            .mapError(DeviceVerificationServiceError.networkError)
            .eraseToAnyPublisher()
    }
}

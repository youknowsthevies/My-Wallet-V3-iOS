// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import DIKit

final class AuthenticationRepository: AuthenticationRepositoryAPI {

    // MARK: - Properties

    private let apiClient: VerifyDeviceClientAPI

    // MARK: - Setup

    init(apiClient: VerifyDeviceClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - AuthenticationRepositoryAPI

    func sendDeviceVerificationEmail(to emailAddress: String, captcha: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        apiClient
            .sendGuidReminder(emailAddress: emailAddress, captcha: captcha)
            .eraseToAnyPublisher()
    }

    func authorizeLogin(sessionToken: String, emailCode: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        apiClient
            .authorizeApprove(sessionToken: sessionToken, emailCode: emailCode)
            .eraseToAnyPublisher()
    }
}

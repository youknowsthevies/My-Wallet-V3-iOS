// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import NetworkError

protocol DeviceVerificationClientAPI {
    func sendGuidReminder(
        sessionToken: String,
        emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, NetworkError>

    func authorizeApprove(
        sessionToken: String,
        emailCode: String
    ) -> AnyPublisher<AuthorizeApproveResponse, NetworkError>

    func pollForWalletInfo(
        sessionToken: String
    ) -> AnyPublisher<WalletInfo?, Never>
}

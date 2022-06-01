// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAuthenticationDomain

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
    ) -> AnyPublisher<WalletInfoPollResultResponse, NetworkError>

    func authorizeVerifyDevice(
        from sessionToken: String,
        payload: String,
        confirmDevice: Bool?
    ) -> AnyPublisher<Void, NetworkError>
}

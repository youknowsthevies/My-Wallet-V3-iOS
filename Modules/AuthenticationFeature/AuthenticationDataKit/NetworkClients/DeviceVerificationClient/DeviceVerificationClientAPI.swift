// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine

protocol DeviceVerificationClientAPI {
    func sendGuidReminder(emailAddress: String, captcha: String) -> AnyPublisher<Void, DeviceVerificationServiceError>
    func authorizeApprove(sessionToken: String, emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError>
}

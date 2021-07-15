// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine

protocol VerifyDeviceClientAPI {
    func sendGuidReminder(emailAddress: String, captcha: String) -> AnyPublisher<Void, AuthenticationServiceError>
    func authorizeApprove(sessionToken: String, emailCode: String) -> AnyPublisher<Void, AuthenticationServiceError>
}

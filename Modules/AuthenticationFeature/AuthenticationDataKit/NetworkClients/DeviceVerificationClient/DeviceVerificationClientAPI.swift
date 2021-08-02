// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

protocol DeviceVerificationClientAPI {
    func sendGuidReminder(emailAddress: String, captcha: String) -> AnyPublisher<Void, NetworkError>
    func authorizeApprove(sessionToken: String, emailCode: String) -> AnyPublisher<Void, NetworkError>
}

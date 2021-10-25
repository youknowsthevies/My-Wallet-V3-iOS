// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

class NoOpKYCVerificationService: KYCVerificationServiceAPI {
    var isKYCVerified: AnyPublisher<Bool, Never> {
        Empty().eraseToAnyPublisher()
    }
}

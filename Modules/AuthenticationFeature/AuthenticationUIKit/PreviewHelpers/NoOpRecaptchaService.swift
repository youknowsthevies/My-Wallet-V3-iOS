// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpRecaptchaService: GoogleRecaptchaServiceAPI {

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        Deferred {
            Future { (_) in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }
}

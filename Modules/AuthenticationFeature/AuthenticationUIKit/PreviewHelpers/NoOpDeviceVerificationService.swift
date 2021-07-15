// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpAuthenticationService: AuthenticationServiceAPI {

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        Deferred {
            Future { (_) in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }

    func sendDeviceVerificationEmail(
        to emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, AuthenticationServiceError> {
        Deferred {
            Future { (_) in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }

    func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        Deferred {
            Future { (_) in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import KYCKit
import ToolKit

#if DEBUG
/// Intented for SwiftUI Previews and only available in DEBUG
class NoOpEmailVerificationService: EmailVerificationServiceAPI {
    
    func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationStatus, EmailVerificationCheckError> {
        Future { (callback) in
            // no-op
        }
        .eraseToAnyPublisher()
    }
    func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Future { (callback) in
            // no-op
        }
        .eraseToAnyPublisher()
    }
    
    func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Future { (callback) in
            // no-op
        }
        .eraseToAnyPublisher()
    }
}
#endif

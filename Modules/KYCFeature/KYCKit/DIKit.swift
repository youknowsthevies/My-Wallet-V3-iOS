// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - KYCKit Module

    public static var kycKit = module {

        single { KYCSettings() as KYCSettingsAPI }
        
        factory { KYCStatusChecker() as KYCStatusChecking }
        
        factory { EmailVerificationService() as EmailVerificationServiceAPI }
    }
}

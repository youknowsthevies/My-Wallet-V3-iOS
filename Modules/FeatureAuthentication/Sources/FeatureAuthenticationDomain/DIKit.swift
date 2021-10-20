// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureAuthenticationDomain Module

    public static var featureAuthenticationDomain = module {

        // MARK: - Services

        factory { JWTService() as JWTServiceAPI }

        factory { AccountRecoveryService() as AccountRecoveryServiceAPI }

        factory { MobileAuthSyncService() as MobileAuthSyncServiceAPI }

        factory { ResetPasswordService() as ResetPasswordServiceAPI }

        single { PasswordValidator() as PasswordValidatorAPI }

        single { SeedPhraseValidator() as SeedPhraseValidatorAPI }
    }
}

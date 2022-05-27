// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import WalletPayloadKit

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

        single { SharedKeyParsingService() }

        // MARK: - NabuAuthentication

        single { NabuAuthenticationExecutor() as NabuAuthenticationExecutorAPI }

        single { NabuAuthenticationErrorBroadcaster() }

        factory { () -> WalletRecoveryService in
            WalletRecoveryService.live(
                walletManager: DIKit.resolve(),
                walletRecovery: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> WalletCreationService in
            WalletCreationService.live(
                walletManager: DIKit.resolve(),
                walletCreator: DIKit.resolve(),
                nabuRepository: DIKit.resolve(),
                nativeWalletCreationEnabled: { nativeWalletCreationFlagEnabled() }
            )
        }

        factory { () -> WalletFetcherService in
            WalletFetcherService.live(
                walletManager: DIKit.resolve(),
                accountRecoveryService: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> NabuAuthenticationErrorReceiverAPI in
            let broadcaster: NabuAuthenticationErrorBroadcaster = DIKit.resolve()
            return broadcaster as NabuAuthenticationErrorReceiverAPI
        }

        factory { () -> UserAlreadyRestoredHandlerAPI in
            let broadcaster: NabuAuthenticationErrorBroadcaster = DIKit.resolve()
            return broadcaster as UserAlreadyRestoredHandlerAPI
        }

        factory { () -> NabuAuthenticationExecutorProvider in
            { () -> NabuAuthenticationExecutorAPI in
                DIKit.resolve()
            } as NabuAuthenticationExecutorProvider
        }
    }
}

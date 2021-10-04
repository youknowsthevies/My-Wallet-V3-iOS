// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain

extension DependencyContainer {

    // MARK: - FeatureAuthenticationData Module

    public static var featureAuthenticationData = module {

        // MARK: - WalletNetworkClients

        factory { AutoWalletPairingClient() as AutoWalletPairingClientAPI }

        factory { GuidClient() as GuidClientAPI }

        factory { SMSClient() as SMSClientAPI }

        factory { SessionTokenClient() as SessionTokenClientAPI }

        factory { TwoFAWalletClient() as TwoFAWalletClientAPI }

        factory { DeviceVerificationClient() as DeviceVerificationClientAPI }

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { PushNotificationsClient() as PushNotificationsClientAPI }

        factory { MobileAuthSyncClient() as MobileAuthSyncClientAPI }

        // MARK: - NabuNetworkClients

        factory { JWTClient() as JWTClientAPI }

        factory { NabuUserCreationClient() as NabuUserCreationClientAPI }

        factory { NabuSessionTokenClient() as NabuSessionTokenClientAPI }

        factory { NabuUserRecoveryClient() as NabuUserRecoveryClientAPI }

        factory { NabuResetUserClient() as NabuResetUserClientAPI }

        // MARK: - Repositories

        factory { JWTRepository() as JWTRepositoryAPI }

        factory { AccountRecoveryRepository() as AccountRecoveryRepositoryAPI }

        factory { DeviceVerificationRepository() as DeviceVerificationRepositoryAPI }

        factory { RemoteSessionTokenRepository() as RemoteSessionTokenRepositoryAPI }

        factory { MobileAuthSyncRepository() as MobileAuthSyncRepositoryAPI }

        factory { PushNotificationsRepository() as PushNotificationsRepositoryAPI }
    }
}

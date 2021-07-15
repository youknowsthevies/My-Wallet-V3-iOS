// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import DIKit

extension DependencyContainer {

    // MARK: - AuthenticationDataKit Module

    public static var authenticationDataKit = module {

        // MARK: - NetworkClients

        factory { AutoWalletPairingClient() as AutoWalletPairingClientAPI }

        factory { GuidClient() as GuidClientAPI }

        factory { SMSClient() as SMSClientAPI }

        factory { SessionTokenClient() as SessionTokenClientAPI }

        factory { TwoFAWalletClient() as TwoFAWalletClientAPI }

        factory { VerifyDeviceClient() as VerifyDeviceClientAPI }

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        // MARK: - Repositories

        factory { AuthenticationRepository() as AuthenticationRepositoryAPI }

    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit
import SettingsKit
import UIKit

struct CoreAppState: Equatable {
    var window: UIWindow?
    var onboarding: Onboarding.State? = .init()
    var loggedIn: LoggedIn.State?
}

public enum CoreAppAction: Equatable {
    case start(window: UIWindow)
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
}

struct CoreAppEnvironment {
    var appFeatureConfigurator: AppFeatureConfigurator
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI
}

let mainAppReducer = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment>.combine(
    onBoardingReducer
        .optional()
        .pullback(
            state: \.onboarding,
            action: /CoreAppAction.onboarding,
            environment: { environment -> Onboarding.Environment in
                Onboarding.Environment(
                    blockchainSettings: environment.blockchainSettings
                )
            }),
    loggedInReducer
        .optional()
        .pullback(
            state: \.loggedIn,
            action: /CoreAppAction.loggedIn,
            environment: { _ -> LoggedIn.Environment in
                LoggedIn.Environment()
            }),
    mainAppReducerCore
)

let mainAppReducerCore = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment> { state, action, environment in
    switch action {
    case .start(let window):
        state.window = window
        return .merge(
            .fireAndForget {
                environment.appFeatureConfigurator.initialize()
            },
            syncPinKeyWithICloud(
                blockchainSettings: environment.blockchainSettings,
                credentialsStore: environment.credentialsStore
            )
        )
    case .onboarding:
        return .none
    case .loggedIn:
        return .none
    }
}

// MARK: Private Methods

private func syncPinKeyWithICloud(blockchainSettings: BlockchainSettings.App,
                                  credentialsStore: CredentialsStoreAPI) -> Effect<CoreAppAction, Never> {
    // In order to login to wallet, we need to know:
    // GUID                 - To look up the wallet
    // SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
    // EncryptedPinPassword - To decrypt the wallet
    // PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the EncryptedPinPassword (EncryptedWalletPassword)
    // PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled

    // In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
    // Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
    // The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
    // The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.
    .fireAndForget {
        guard !blockchainSettings.isPairedWithWallet else {
            // Wallet is Paired, we do not need to restore.
            // We will back up after pin authentication
            return
        }

        if blockchainSettings.pinKey == nil,
           blockchainSettings.encryptedPinPassword == nil,
           blockchainSettings.guid == nil,
           blockchainSettings.sharedKey == nil {

            credentialsStore.synchronize()

            // Attempt to restore the pinKey from iCloud
            if let pinData = credentialsStore.pinData() {
                blockchainSettings.pinKey = pinData.pinKey
                blockchainSettings.encryptedPinPassword = pinData.encryptedPinPassword
            }
        }
    }
}

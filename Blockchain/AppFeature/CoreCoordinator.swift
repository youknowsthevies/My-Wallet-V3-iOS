// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import UIKit
import WalletPayloadKit

struct CoreAppState: Equatable {
    var window: UIWindow?
    var onboarding: Onboarding.State? = .init()
    var loggedIn: LoggedIn.State?
}

public enum CoreAppAction: Equatable {
    case start(window: UIWindow)
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
    case walletInitialized
    case walletNeedsUpgrade(Bool)
    case proceedToLoggedIn
    case none
}

struct CoreAppEnvironment {
    var walletManager: WalletManager
    var appFeatureConfigurator: FeatureConfiguratorAPI
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI
    var alertPresenter: AlertViewPresenterAPI
    var walletUpgradeService: WalletUpgradeServicing
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var coincore: CoincoreAPI
}

let mainAppReducer = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment>.combine(
    onBoardingReducer
        .optional()
        .pullback(
            state: \.onboarding,
            action: /CoreAppAction.onboarding,
            environment: { environment -> Onboarding.Environment in
                Onboarding.Environment(
                    blockchainSettings: environment.blockchainSettings,
                    walletManager: environment.walletManager,
                    alertPresenter: environment.alertPresenter
                )
            }),
    loggedInReducer
        .optional()
        .pullback(
            state: \.loggedIn,
            action: /CoreAppAction.loggedIn,
            environment: { environment -> LoggedIn.Environment in
                LoggedIn.Environment(
                    exchangeRepository: environment.exchangeRepository,
                    remoteNotificationTokenSender: environment.remoteNotificationServiceContainer.tokenSender,
                    remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                    walletManager: environment.walletManager,
                    coincore: environment.coincore
                )
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
            .fireAndForget {
                syncPinKeyWithICloud(
                    blockchainSettings: environment.blockchainSettings,
                    credentialsStore: environment.credentialsStore
                )
            }
        )
    case .onboarding(.pin(.authenticated(.success))):
        return environment.walletManager
            .reactiveWallet
            .waitUntilInitializedSinglePublisher
            .catchToEffect()
            .map { _ in CoreAppAction.walletInitialized }
    case .walletInitialized:
        // TODO: Handle second password as well
        return environment.walletUpgradeService
            .needsWalletUpgradePublisher
            .catchToEffect()
            .map { result -> CoreAppAction in
                guard case .success(let shouldUpgrade) = result else {
                    // impossible with current `WalletUpgradeServicing` implementation
                    return CoreAppAction.proceedToLoggedIn
                }
                return CoreAppAction.walletNeedsUpgrade(shouldUpgrade)
            }
    case .walletNeedsUpgrade(let shouldUpgrade):
        // check if we need the wallet needs an upgrade otherwise proceed to logged in state
        guard shouldUpgrade else {
            return Effect(value: CoreAppAction.proceedToLoggedIn)
        }
        state.onboarding?.pinState = nil
        state.onboarding?.walletUpgradeState = WalletUpgrade.State()
        return Effect(value: CoreAppAction.onboarding(.walletUpgrade(.begin)))
    case .proceedToLoggedIn:
        state.loggedIn = LoggedIn.State()
        state.onboarding = nil
        return Effect(value: CoreAppAction.loggedIn(.start(window: state.window)))
    case .onboarding(.walletUpgrade(.completed)):
        return Effect(value: CoreAppAction.proceedToLoggedIn)
    case .onboarding:
        return .none
    case .loggedIn:
        return .none
    case .none:
        return .none
    }
}

// MARK: Private Methods

/// - Note:
/// In order to login to wallet, we need to know:
/// - GUID                 - To look up the wallet
/// - SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
/// - EncryptedPinPassword - To decrypt the wallet
/// - PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the -  EncryptedPinPassword (EncryptedWalletPassword)
/// - PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled
///
/// In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
/// Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
///
/// The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
///
/// The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.
internal func syncPinKeyWithICloud(blockchainSettings: BlockchainSettings.App,
                                   credentialsStore: CredentialsStoreAPI) {
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

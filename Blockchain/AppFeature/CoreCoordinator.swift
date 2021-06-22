// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import UIKit
import WalletPayloadKit

/// Used for canceling publishers
private struct WalletCancelations {
    struct DecryptId: Hashable {}
    struct AuthenticationId: Hashable {}
    struct InitializationId: Hashable {}
    struct UpgradeId: Hashable {}
}

struct CoreAppState: Equatable {
    var window: UIWindow?
    var onboarding: Onboarding.State? = .init()
    var loggedIn: LoggedIn.State?
}

public enum CoreAppAction: Equatable {
    case start(window: UIWindow)
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
    case proceedToLoggedIn
    case appForegrounded
    // Wallet Related Actions
    case walletInitialized
    case fetchWallet(String)
    case authenticate
    case didDecryptWallet(WalletDecryption)
    case decryptionFailure(AuthenticationError)
    case authenticated(Result<Bool, AuthenticationError>)
    case setupPin
    case initializeWallet
    case walletNeedsUpgrade(Bool)
    case none
}

struct CoreAppEnvironment {
    var loadingViewPresenter: LoadingViewPresenting
    var walletManager: WalletManager
    var appFeatureConfigurator: FeatureConfiguratorAPI
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI
    var alertPresenter: AlertViewPresenterAPI
    var walletUpgradeService: WalletUpgradeServicing
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var coincore: CoincoreAPI
    var sharedContainer: SharedContainerUserDefaults
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var siftService: SiftServiceAPI
    var onboardingSettings: OnboardingSettingsAPI
    var mainQueue: AnySchedulerOf<DispatchQueue>
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
                    alertPresenter: environment.alertPresenter,
                    mainQueue: .main
                )
            }),
    loggedInReducer
        .optional()
        .pullback(
            state: \.loggedIn,
            action: /CoreAppAction.loggedIn,
            environment: { environment -> LoggedIn.Environment in
                LoggedIn.Environment(
                    analyticsRecorder: environment.analyticsRecorder,
                    loadingViewPresenter: environment.loadingViewPresenter,
                    exchangeRepository: environment.exchangeRepository,
                    remoteNotificationTokenSender: environment.remoteNotificationServiceContainer.tokenSender,
                    remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                    walletManager: environment.walletManager,
                    coincore: environment.coincore,
                    appSettings: environment.blockchainSettings
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
    case .appForegrounded:
        // check if we need to display the pin for authentication
        guard environment.walletManager.wallet.isInitialized() else {
            state.loggedIn = nil
            state.onboarding = .init()
            return Effect(value: .onboarding(.start))
        }
        return .none
    case .fetchWallet(let password):
        environment.walletManager.wallet.fetch(with: password)
        return Effect(value: .authenticate)
    case .authenticate:
        let appSettings = environment.blockchainSettings
        return .merge(
            environment.walletManager.didDecryptWallet
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.DecryptId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case let .success(value) = result else {
                        return .none
                    }
                    return handleWalletDecryption(value)
                },
            environment.walletManager.didCompleteAuthentication
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.AuthenticationId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case let .success(value) = result else {
                        return CoreAppAction.authenticated(
                            .failure(.init(code: AuthenticationError.ErrorCode.unknown))
                        )
                    }
                    return CoreAppAction.authenticated(value)
                }
        )
    case .didDecryptWallet(let decryption):
        environment.blockchainSettings.guid = decryption.guid
        environment.blockchainSettings.sharedKey = decryption.sharedKey

        return .merge(
            .cancel(id: WalletCancelations.DecryptId()),
            .fireAndForget {
                clearPinIfNeeded(
                    for: decryption.passwordPartHash,
                    appSettings: environment.blockchainSettings
                )
            }
        )
    case .decryptionFailure(let error):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.DecryptId())
    case .authenticated(.failure(let error)):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.AuthenticationId())
    case .authenticated(.success):
        // decide if we need to set a pin or not
        guard environment.blockchainSettings.isPinSet else {
            state.onboarding?.hideLegacyScreenIfNeeded()
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(value: .setupPin)
            )
        }
        return .merge(
            .cancel(id: WalletCancelations.AuthenticationId()),
            Effect(value: .initializeWallet)
        )
    case .setupPin:
        state.onboarding?.pinState = .init()
        state.onboarding?.passwordScreen = nil
        return Effect(value: CoreAppAction.onboarding(.pin(.create)))
    case .initializeWallet:
        return environment.walletManager
            .reactiveWallet
            .waitUntilInitializedSinglePublisher
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.InitializationId(), cancelInFlight: false)
            .map { _ in CoreAppAction.walletInitialized }
    case .walletInitialized:
        // TODO: Handle second password as well
        return environment.walletUpgradeService
            .needsWalletUpgradePublisher
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.UpgradeId(), cancelInFlight: false)
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
        return .merge(
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(value: CoreAppAction.onboarding(.walletUpgrade(.begin)))
        )
    case .proceedToLoggedIn:
        state.loggedIn = LoggedIn.State()
        state.onboarding = nil
        return .merge(
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(
                value: CoreAppAction.loggedIn(.start)
            )
        )
    case .onboarding(.welcomeScreen(.createAccount)),
         .onboarding(.welcomeScreen(.recoverFunds)):
        // send `authenticate` action so that we can listen for wallet creation or recovery
        return Effect(value: .authenticate)
    case .onboarding(.createAccountScreenClosed),
         .onboarding(.recoverWalletScreenClosed):
        // cancel any authentication publishers in case the create wallet is closed
        return .merge(
            .cancel(id: WalletCancelations.DecryptId()),
            .cancel(id: WalletCancelations.AuthenticationId())
        )
    case .onboarding(.walletUpgrade(.completed)):
        return Effect(
            value: CoreAppAction.proceedToLoggedIn
        )
    case .onboarding(.passwordScreen(.authenticate(let password))):
        return Effect(
            value: .fetchWallet(password)
        )
    case .onboarding(.pin(.handleAuthentication(let password))):
        return Effect(
            value: .fetchWallet(password)
        )
    case .onboarding(.pin(.pinCreated)):
        return Effect(
            value: .initializeWallet
        )
    case .onboarding(.pin(.logout)),
         .loggedIn(.logout):
        // reset
        environment.walletManager.close()

        NotificationCenter.default.post(name: .logout, object: nil)
        environment.analyticsRecorder.record(event: AnalyticsEvents.New.Navigation.signedOut)

        environment.siftService.removeUserId()
        environment.sharedContainer.reset()
        environment.blockchainSettings.reset()
        environment.onboardingSettings.reset()

        // update state
        state.loggedIn = nil
        state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        // show password screen
        return Effect(value: .onboarding(.passwordScreen(.start)))
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

func handleWalletDecryption(_ decryption: WalletDecryption) -> CoreAppAction {

    //// Verify valid GUID and sharedKey
    guard let guid = decryption.guid, guid.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            )
        )
    }

    guard let sharedKey = decryption.sharedKey, sharedKey.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey,
                description: LocalizationConstants.Authentication.invalidSharedKey
            )
        )
    }

    return .didDecryptWallet(decryption)
}

func clearPinIfNeeded(for passwordPartHash: String?, appSettings: BlockchainSettings.App) {
    // Because we are not storing the password on the device. We record the first few letters of the hashed password.
    // With the hash prefix we can then figure out if the password changed. If so, clear the pin
    // so that the user can reset it
    guard let passwordPartHash = passwordPartHash,
          let savedPasswordPartHash = appSettings.passwordPartHash else {
        return
    }

    guard passwordPartHash != savedPasswordPartHash else {
        return
    }

    appSettings.clearPin()
}

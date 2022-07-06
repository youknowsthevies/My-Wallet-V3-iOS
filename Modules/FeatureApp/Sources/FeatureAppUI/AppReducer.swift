// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import ToolKit
import UIKit
import WalletPayloadKit

enum AppCancellations {
    struct DeeplinkId: Hashable {}
    struct WalletPersistenceId: Hashable {}
}

public struct AppState: Equatable {
    public var appSettings: AppDelegateState = .init()
    public var coreState: CoreAppState = .init()

    public init(
        appSettings: AppDelegateState = .init(),
        coreState: CoreAppState = .init()
    ) {
        self.appSettings = appSettings
        self.coreState = coreState
    }
}

public enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case core(CoreAppAction)
    case walletPersistence(WalletPersistenceAction)
    case none
}

public enum WalletPersistenceAction: Equatable {
    case begin
    case cancel
    case persisted(Result<EmptyValue, WalletRepoPersistenceError>)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    appDelegateReducer
        .pullback(
            state: \.appSettings,
            action: /AppAction.appDelegate,
            environment: {
                AppDelegateEnvironment(
                    app: $0.app,
                    appSettings: $0.blockchainSettings,
                    cacheSuite: $0.cacheSuite,
                    remoteNotificationBackgroundReceiver: $0.remoteNotificationServiceContainer.backgroundReceiver,
                    remoteNotificationAuthorizer: $0.remoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenReceiver: $0.remoteNotificationServiceContainer.tokenReceiver,
                    certificatePinner: $0.certificatePinner,
                    siftService: $0.siftService,
                    blurEffectHandler: $0.blurEffectHandler,
                    customerSupportChatService: $0.customerSupportChatService,
                    backgroundAppHandler: $0.backgroundAppHandler,
                    supportedAssetsRemoteService: $0.supportedAssetsRemoteService,
                    featureFlagService: $0.featureFlagsService,
                    observabilityService: $0.observabilityService,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    mainAppReducer
        .pullback(
            state: \.coreState,
            action: /AppAction.core,
            environment: { env in
                CoreAppEnvironment(
                    app: env.app,
                    nabuUserService: env.nabuUserService,
                    loadingViewPresenter: env.loadingViewPresenter,
                    externalAppOpener: env.externalAppOpener,
                    deeplinkHandler: env.deeplinkHandler,
                    deeplinkRouter: env.deeplinkRouter,
                    walletManager: env.walletManager,
                    mobileAuthSyncService: env.mobileAuthSyncService,
                    pushNotificationsRepository: env.pushNotificationsRepository,
                    resetPasswordService: env.resetPasswordService,
                    accountRecoveryService: env.accountRecoveryService,
                    userService: env.userService,
                    deviceVerificationService: env.deviceVerificationService,
                    featureFlagsService: env.featureFlagsService,
                    fiatCurrencySettingsService: env.fiatCurrencySettingsService,
                    blockchainSettings: env.blockchainSettings,
                    credentialsStore: env.credentialsStore,
                    alertPresenter: env.alertViewPresenter,
                    walletUpgradeService: env.walletUpgradeService,
                    exchangeRepository: env.exchangeRepository,
                    remoteNotificationServiceContainer: env.remoteNotificationServiceContainer,
                    coincore: env.coincore,
                    erc20CryptoAssetService: env.erc20CryptoAssetService,
                    sharedContainer: env.sharedContainer,
                    analyticsRecorder: env.analyticsRecorder,
                    siftService: env.siftService,
                    mainQueue: env.mainQueue,
                    appStoreOpener: env.appStoreOpener,
                    walletPayloadService: env.walletPayloadService,
                    walletService: env.walletService,
                    forgetWalletService: env.forgetWalletService,
                    secondPasswordPrompter: env.secondPasswordPrompter,
                    nativeWalletFlagEnabled: { nativeWalletFlagEnabled() },
                    buildVersionProvider: env.buildVersionProvider,
                    performanceTracing: env.performanceTracing,
                    appUpgradeState: {
                        let service = AppUpgradeStateService(
                            deviceInfo: env.deviceInfo,
                            featureFetcher: env.featureFlagsService
                        )
                        return service.state
                    }
                )
            }
        ),
    appReducerCore
)

// swiftlint:disable closure_body_length
let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .appDelegate(.didFinishLaunching):
        return .init(value: .core(.start))
    case .appDelegate(.didEnterBackground):
        return .none
    case .appDelegate(.willEnterForeground):
        return Effect(value: .core(.appForegrounded))
    case .appDelegate(.handleDelayedEnterBackground):
        if environment.openBanking.isAuthorising {
            return .none
        }
        if environment.cardService.isEnteringDetails {
            return .none
        }
        return .merge(
            .fireAndForget {
                if environment.walletManager.walletIsInitialized() {
                    if environment.blockchainSettings.guid != nil, environment.blockchainSettings.sharedKey != nil {
                        environment.blockchainSettings.hasEndedFirstSession = true
                    }
                    environment.walletManager.close()
                }
            },
            .fireAndForget {
                environment.urlSession.reset {
                    Logger.shared.debug("URLSession reset completed.")
                }
            }
        )
    case .appDelegate(.userActivity(let activity)):
        state.appSettings.userActivityHandled = environment.deeplinkAppHandler.canHandle(
            deeplink: .userActivity(activity)
        )
        return environment.deeplinkAppHandler
            .handle(deeplink: .userActivity(activity))
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: AppCancellations.DeeplinkId())
            .map { result in
                guard let data = result.successData else {
                    return AppAction.core(.none)
                }
                return AppAction.core(.deeplink(data))
            }
    case .appDelegate(.open(let url)):
        state.appSettings.urlHandled = environment.deeplinkAppHandler.canHandle(deeplink: .url(url))
        return environment.deeplinkAppHandler
            .handle(deeplink: .url(url))
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: AppCancellations.DeeplinkId())
            .map { result in
                guard let data = result.successData else {
                    return AppAction.core(.none)
                }
                return AppAction.core(.deeplink(data))
            }
    case .core(.onboarding(.forgetWallet)):
        return .none
    case .core(.start):
        return .merge(
            environment.app
                .publisher(for: blockchain.app.configuration.native.wallet.payload.is.enabled, as: Bool.self)
                .prefix(1)
                .replaceError(with: false)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { isEnabled in
                    guard isEnabled else {
                        return .none
                    }
                    return .walletPersistence(.begin)
                },
            Effect(value: .core(.onboarding(.start)))
        )
    case .walletPersistence(.begin):
        let crashlyticsRecorder = environment.crashlyticsRecorder
        return environment.walletRepoPersistence
            .beginPersisting()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(
                id: AppCancellations.WalletPersistenceId(),
                cancelInFlight: true
            )
            .map { AppAction.walletPersistence(.persisted($0)) }
    case .walletPersistence(.persisted(.failure(let error))):
        // record the error if we encounter one and restart the persistence
        environment.crashlyticsRecorder.error(error)
        return .concatenate(
            .cancel(id: AppCancellations.WalletPersistenceId()),
            Effect(value: .walletPersistence(.begin))
        )
    case .walletPersistence(.persisted(.success)):
        return .none
    case .none:
        return .none
    default:
        return .none
    }
}

// swiftlint:enable closure_body_length

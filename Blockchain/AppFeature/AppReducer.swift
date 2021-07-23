// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import SettingsKit
import ToolKit

enum AppCancellations {
    struct DeeplinkId: Hashable {}
}

public struct AppState: Equatable {
    var appSettings: AppDelegateState = .init()
    var coreState: CoreAppState = .init()
}

public enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case core(CoreAppAction)
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    appDelegateReducer
        .pullback(
            state: \.appSettings,
            action: /AppAction.appDelegate,
            environment: {
                AppDelegateEnvironment(
                    appSettings: $0.blockchainSettings,
                    debugCoordinator: $0.debugCoordinator,
                    onboardingSettings: $0.onboardingSettings,
                    cacheSuite: $0.cacheSuite,
                    remoteNotificationAuthorizer: $0.remoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenReceiver: $0.remoteNotificationServiceContainer.tokenReceiver,
                    certificatePinner: $0.certificatePinner,
                    siftService: $0.siftService,
                    blurEffectHandler: $0.blurEffectHandler,
                    backgroundAppHandler: $0.backgroundAppHandler
                )
            }
        ),
    mainAppReducer
        .pullback(
            state: \.coreState,
            action: /AppAction.core,
            environment: {
                CoreAppEnvironment(
                    loadingViewPresenter: $0.loadingViewPresenter,
                    deeplinkHandler: $0.deeplinkHandler,
                    deeplinkRouter: $0.deeplinkRouter,
                    walletManager: $0.walletManager,
                    featureFlagsService: $0.featureFlagsService,
                    appFeatureConfigurator: $0.appFeatureConfigurator,
                    internalFeatureService: $0.internalFeatureService,
                    fiatCurrencySettingsService: $0.fiatCurrencySettingsService,
                    blockchainSettings: $0.blockchainSettings,
                    credentialsStore: $0.credentialsStore,
                    alertPresenter: resolve(),
                    walletUpgradeService: $0.walletUpgradeService,
                    exchangeRepository: $0.exchangeRepository,
                    remoteNotificationServiceContainer: $0.remoteNotificationServiceContainer,
                    coincore: resolve(),
                    sharedContainer: $0.sharedContainer,
                    analyticsRecorder: $0.analyticsRecorder,
                    siftService: resolve(),
                    onboardingSettings: $0.onboardingSettings,
                    mainQueue: $0.mainQueue,
                    buildVersionProvider: $0.buildVersionProvider
                )
            }
        ),
    appReducerCore
)

let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .appDelegate(.didFinishLaunching(let window)):
        guard !newOnboardingDisabled() else {
            return .fireAndForget {
                environment.appCoordinator.window = window
                environment.appCoordinator.start()
            }
        }
        return .init(value: .core(.start))
    case .appDelegate(.didEnterBackground):
        return .fireAndForget {
            environment.portfolioSyncingService.sync()
        }
    case .appDelegate(.willEnterForeground):
        guard !newOnboardingDisabled() else {
            return .fireAndForget {
                handleWillEnterForeground(coordinator: environment.appCoordinator)
            }
        }
        return Effect(value: .core(.appForegrounded))
    case .appDelegate(.handleDelayedEnterBackground):
        return .merge(
            .fireAndForget {
                if environment.walletManager.wallet.isInitialized() {
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
            .catchToEffect()
            .cancellable(id: AppCancellations.DeeplinkId())
            .map { result in
                guard let data = result.successData else {
                    return AppAction.core(.none)
                }
                return AppAction.core(.deeplink(data))
            }
    case .core(.start):
        return .init(value: .core(.onboarding(.start)))
    default:
        return .none
    }
}

@available(*, deprecated, message: "this is for compatibility, it should be removed when we add onBoardingReducer")
private func handleWillEnterForeground(coordinator: AppCoordinator) {
    if !WalletManager.shared.wallet.isInitialized() {
        if BlockchainSettings.App.shared.guid != nil, BlockchainSettings.App.shared.sharedKey != nil {
            AuthenticationCoordinator.shared.start()
        } else {
            if coordinator.onboardingRouter.state == .standard {
                coordinator.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
            }
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import SettingsKit

public struct AppState: Equatable {
    var appSettings: AppDelegateState = .init()
    var coreState: CoreAppState = .init()

    /// `true` if a user activiy was handled, such as universal links, otherwise `false`
    var userActivityHandled: Bool = false
    /// `true` if a deep link was handled, otherwise `false`
    var urlHandled: Bool = false
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
            }),
    mainAppReducer
        .pullback(
            state: \.coreState,
            action: /AppAction.core,
            environment: {
                CoreAppEnvironment(
                    walletManager: $0.walletManager,
                    appFeatureConfigurator: $0.appFeatureConfigurator,
                    blockchainSettings:  $0.blockchainSettings,
                    credentialsStore: $0.credentialsStore,
                    alertPresenter: resolve(),
                    walletUpgradeService: $0.walletUpgradeService,
                    exchangeRepository: $0.exchangeRepository,
                    remoteNotificationServiceContainer: $0.remoteNotificationServiceContainer,
                    coincore: resolve()
                )
            }),
    appReducerCore
)

let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .appDelegate(.didFinishLaunching(let window)):
        guard !environment.internalFeatureService.isEnabled(.newOnboarding) else {
            return .init(value: .core(.start(window: window)))
        }
        return .fireAndForget {
            environment.appCoordinator.window = window
            environment.appCoordinator.start()
        }
    case .appDelegate(.didEnterBackground):
        return .fireAndForget {
            environment.portfolioSyncingService.sync()
        }
    case .appDelegate(.willEnterForeground):
        guard !environment.internalFeatureService.isEnabled(.newOnboarding) else {
            // TODO: Handle coming back from background
            return .none
        }
        return .fireAndForget {
            handleWillEnterForeground(coordinator: environment.appCoordinator)
        }
    case .appDelegate(.userActivity(let activity)):
        state.userActivityHandled = environment.userActivityHandler.handle(userActivity: activity)
        return .none
    case .appDelegate(.open(let url)):
        state.urlHandled = environment.deeplinkAppHandler.handle(url: url)
        return .none
    case .core(.start):
        return .init(value: .core(.onboarding(.start)))
    default:
        return .none
    }
}

@available(*, deprecated, message: "this is for compatibility, it should be removed when we add onBoardingReducer")
private func handleWillEnterForeground(coordinator: AppCoordinator) {
    if !WalletManager.shared.wallet.isInitialized() {
        if BlockchainSettings.App.shared.guid != nil && BlockchainSettings.App.shared.sharedKey != nil {
            AuthenticationCoordinator.shared.start()
        } else {
            if coordinator.onboardingRouter.state == .standard {
                coordinator.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
            }
        }
    }
}

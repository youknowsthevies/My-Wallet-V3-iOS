// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AuthenticationKit
import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RxSwift
import SettingsKit
import ToolKit
import WalletPayloadKit

struct LoggedInIdentifier: Hashable {}

public enum LoggedIn {
    /// Transient context to be used as part of start method
    public enum Context: Equatable {
        case wallet(WalletCreationContext)
        case deeplink(URIContent)
        case none
    }

    public enum Action: Equatable {
        case none
        case start(LoggedIn.Context)
        case logout
        case deeplink(URIContent)
        case deeplinkHandled
        // wallet related actions
        case wallet(WalletAction)
        case handleNewWalletCreation
        case showLegacyBuyFlow
        // symbol change actions, used by old address screen
        case symbolChanged
        case symbolChangedHandled
    }

    public struct State: Equatable {
        var reloadAfterSymbolChanged: Bool = false
        var reloadAfterMultiAddressResponse: Bool = false
        var displaySendCryptoScreen: Bool = false
        var displayOnboardingFlow: Bool = false
        var displayLegacyBuyFlow: Bool = false
        var displayWalletAlertContent: AlertViewContent?
    }

    public struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        var analyticsRecorder: AnalyticsEventRecorderAPI
        var loadingViewPresenter: LoadingViewPresenting
        var exchangeRepository: ExchangeAccountRepositoryAPI
        var remoteNotificationTokenSender: RemoteNotificationTokenSending
        var remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
        var walletManager: WalletManager
        var coincore: CoincoreAPI
        var appSettings: BlockchainSettings.App
        var deeplinkRouter: DeepLinkRouting
        var internalFeatureService: InternalFeatureFlagServiceAPI
        var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    }

    public enum WalletAction: Equatable {
        case authenticateForBiometrics(password: String)
        case accountInfoAndExchangeRates
        case accountInfoAndExchangeRatesHandled
        case handleWalletBackup
        case handleFailToLoadHistory(String?)
    }
}

let loggedInReducer = Reducer<LoggedIn.State, LoggedIn.Action, LoggedIn.Environment> { state, action, environment in
    switch action {
    case .start(let context):
        return .merge(
            .run { subscriber in
                environment.appSettings.onSymbolLocalChanged = { _ in
                    subscriber.send(.symbolChanged)
                }
                return AnyCancellable {
                    environment.appSettings.onSymbolLocalChanged = nil
                }
            }
            .cancellable(id: LoggedInIdentifier()),
            environment.walletManager.walletDidGetAccountInfoAndExchangeRates
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.accountInfoAndExchangeRates) },
            environment.walletManager.walletBackupFailed
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.handleWalletBackup) },
            environment.walletManager.walletBackupSuccess
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { _ in LoggedIn.Action.wallet(.handleWalletBackup) },
            environment.walletManager.walletFailedToGetHistory
                .catchToEffect()
                .cancellable(id: LoggedInIdentifier())
                .map { result in
                    guard case .success(let error) = result else {
                        return .none
                    }
                    return LoggedIn.Action.wallet(.handleFailToLoadHistory(error))
                },
            environment.exchangeRepository
                .syncDepositAddressesIfLinkedPublisher()
                .ignoreOutput()
                .catchToEffect()
                .fireAndForget(),
            environment.remoteNotificationTokenSender
                .sendTokenIfNeededPublisher()
                .ignoreOutput()
                .catchToEffect()
                .fireAndForget(),
            environment.remoteNotificationAuthorizer
                .requestAuthorizationIfNeededPublisher()
                .ignoreOutput()
                .catchToEffect()
                .fireAndForget(),
            environment.coincore.initializePublisher()
                .ignoreOutput()
                .catchToEffect()
                .fireAndForget(),
            .fireAndForget {
                NotificationCenter.default.post(name: .login, object: nil)
            },
            handleStartup(context: context)
        )
    case .deeplink(let content):
        let context = content.context
        guard context == .executeDeeplinkRouting else {
            guard context == .sendCrypto else {
                return Effect(value: .deeplinkHandled)
            }
            state.displaySendCryptoScreen = true
            return Effect(value: .deeplinkHandled)
        }
        // perform legacy routing
        environment.deeplinkRouter.routeIfNeeded()
        return .none
    case .deeplinkHandled:
        // clear up state
        state.displaySendCryptoScreen = false
        return .none
    case .handleNewWalletCreation:
        guard environment.internalFeatureService.isEnabled(.showOnboardingAfterSignUp) else {
            // display old buy flow
            return environment.fiatCurrencySettingsService
                .update(currency: .locale, context: .walletCreation)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> LoggedIn.Action in
                    guard case .success = result else {
                        return .none
                    }
                    return .showLegacyBuyFlow
                }
        }
        // display new onboarding flow
        state.displayOnboardingFlow = true
        return .none
    case .showLegacyBuyFlow:
        state.displayLegacyBuyFlow = true
        return .none
    case .logout:
        return .cancel(id: LoggedInIdentifier())
    case .wallet(.authenticateForBiometrics):
        return .cancel(id: LoggedInIdentifier())
    case .wallet(.accountInfoAndExchangeRates):
        environment.loadingViewPresenter.hide()
        state.reloadAfterMultiAddressResponse = true
        return Effect(value: .wallet(.accountInfoAndExchangeRatesHandled))
    case .wallet(.accountInfoAndExchangeRatesHandled):
        state.reloadAfterMultiAddressResponse = false
        return .none
    case .wallet(.handleWalletBackup):
        environment.walletManager.wallet.getHistoryForAllAssets()
        return .none
    case .wallet(.handleFailToLoadHistory(let error)):
        guard let errorMessage = error, errorMessage.count > 0 else {
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
            return .none
        }
        environment.analyticsRecorder.record(
            event: AnalyticsEvents.AppCoordinatorEvent.btcHistoryError(errorMessage)
        )
        state.displayWalletAlertContent = AlertViewContent(
            title: LocalizationConstants.Errors.error,
            message: LocalizationConstants.Errors.balancesGeneric
        )
        return .none
    case .symbolChanged:
        state.reloadAfterSymbolChanged = true
        return Effect(value: .symbolChangedHandled)
    case .symbolChangedHandled:
        state.reloadAfterSymbolChanged = false
        return .none
    case .none:
        return .none
    }
}

// MARK: Private

/// Handle the context of a logged in state, eg wallet creation, deeplink, etc
/// - Parameter context: A `LoggedIn.Context` to be taken into account after logging in
/// - Returns: An `Effect<LoggedIn.Action, Never>` based on the context
private func handleStartup(context: LoggedIn.Context) -> Effect<LoggedIn.Action, Never> {
    switch context {
    case .wallet(let walletContext) where walletContext.isNew:
        return Effect(value: .handleNewWalletCreation)
    case .wallet:
        // ignore existing/recovery wallet context
        return .none
    case .deeplink(let deeplinkContent):
        return Effect(value: .deeplink(deeplinkContent))
    case .none:
        return .none
    }
}

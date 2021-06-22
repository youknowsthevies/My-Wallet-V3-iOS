// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import WalletPayloadKit

struct LoggedInIdentifier: Hashable {}

public enum LoggedIn {
    public enum Action: Equatable {
        case none
        case start
        case logout
        // wallet related actions
        case wallet(WalletAction)
        // symbol change actions, used by old address screen
        case symbolChanged
        case symbolChangedHandled
    }

    public struct State: Equatable {
        var reloadAfterSymbolChanged: Bool = false
        var reloadAfterMultiAddressResponse: Bool = false
        var displayWalletAlertContent: AlertViewContent?
    }

    public struct Environment {
        var analyticsRecorder: AnalyticsEventRecorderAPI
        var loadingViewPresenter: LoadingViewPresenting
        var exchangeRepository: ExchangeAccountRepositoryAPI
        var remoteNotificationTokenSender: RemoteNotificationTokenSending
        var remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
        var walletManager: WalletManager
        var coincore: CoincoreAPI
        var appSettings: BlockchainSettings.App
    }

    public enum WalletAction: Equatable {
        case accountInfoAndExchangeRates
        case accountInfoAndExchangeRatesHandled
        case handleWalletBackup
        case handleFailToLoadHistory(String?)
    }
}

let loggedInReducer = Reducer<LoggedIn.State, LoggedIn.Action, LoggedIn.Environment> { state, action, environment in
    switch action {
    case .none:
        return .none
    case .start:
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
            handlePostAuthenticationLogic(environment: environment)
        )
    case .logout:
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
    }
}

// MARK: Private

private func handlePostAuthenticationLogic(environment: LoggedIn.Environment) -> Effect<LoggedIn.Action, Never> {
    Effect<LoggedIn.Action, Never>.merge(
        /// If the user has linked to the Exchange, we sync their addresses on authentication.
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
        }
    )

    // TODO: Handle all this logic as well
    //    if isCreatingWallet {
    //        if featureFlagsService.isEnabled(.showEmailVerificationAtLogin) {
    //            presentEmailVerificationFlow()
    //        } else {
    //            presentSimpleBuyFlow()
    //        }
    //    }
    //
    //    if let route = postAuthenticationRoute {
    //        switch route {
    //        case .sendCoins:
    //            AppCoordinator.shared.tabControllerManager?.showSend()
    //        }
    //        postAuthenticationRoute = nil
    //    }

    // Handle airdrop routing
    //    deepLinkRouter.routeIfNeeded()
}

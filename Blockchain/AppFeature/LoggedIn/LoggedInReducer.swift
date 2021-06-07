// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit
import RemoteNotificationsKit
import WalletPayloadKit

public enum LoggedIn {
    public enum Action: Equatable {
        case none
        case start(window: UIWindow?)
        case toggleSideMenu
    }

    public struct State: Equatable {
        var window: UIWindow?
    }

    public struct Environment {
        var exchangeRepository: ExchangeAccountRepositoryAPI
        var remoteNotificationTokenSender: RemoteNotificationTokenSending
        var remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
        var walletManager: WalletManager
        var coincore: Coincore
    }
}

let loggedInReducer = Reducer<LoggedIn.State, LoggedIn.Action, LoggedIn.Environment> { state, action, environment in
    switch action {
    case .none:
        return .none
    case .toggleSideMenu:
        return .none
    case .start(let window):
        return handlePostAuthenticationLogic(environment: environment)
    }
}

// MARK: Private

private func handlePostAuthenticationLogic(environment: LoggedIn.Environment) -> Effect<LoggedIn.Action, Never> {
    Effect<LoggedIn.Action, Never>.merge(
        .fireAndForget {
            environment.walletManager.wallet.ethereum
                .walletDidLoad()
        },
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

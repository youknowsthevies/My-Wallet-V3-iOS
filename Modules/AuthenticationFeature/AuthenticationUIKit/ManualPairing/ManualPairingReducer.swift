// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import ComposableArchitecture
import DIKit
import Localization
import ToolKit

public enum ManualPairing {
    enum Cancelations: Equatable {
        struct SessionTokenId: Hashable {}
        struct LoginId: Hashable {}
    }

    public enum Action: Equatable {
        public enum AlertAction: Equatable {
            case show(title: String, message: String)
            case dismiss
        }

        case none
        case alert(AlertAction)
        case `continue`
        case login
        case authenticate(password: String)
        case walletIdentifier(String)
        case password(PasswordAction)
        case closeButtonTapped
    }

    public struct State: Equatable {
        var walletIdentifier: String = ""
        var incorrectWalletIdentifier = false
        var passwordState: PasswordState = .init()
        var alertState: AlertState<ManualPairing.Action>?
        var isLoggingIn: Bool = false

        var isValid: Bool {
            isWalletIdentifierValid && passwordState.isValid
        }

        var isWalletIdentifierValid: Bool {
            !incorrectWalletIdentifier && !walletIdentifier.isEmpty
        }
    }

    public struct Environment {
        typealias WalletValidation = (String) -> Bool

        let mainQueue: AnySchedulerOf<DispatchQueue>
        let sessionTokenService: SessionTokenServiceAPI
        let loginService: LoginServiceAPI
        let wallet: WalletAuthenticationKitWrapper
        let featureFlags: FeatureFlagsServiceAPI
        let walletIdentifierValidation: WalletValidation

        init(
            mainQueue: AnySchedulerOf<DispatchQueue> = .main,
            sessionTokenService: SessionTokenServiceAPI = resolve(),
            loginService: LoginServiceAPI = resolve(),
            featureFlags: FeatureFlagsServiceAPI = resolve(),
            wallet: WalletAuthenticationKitWrapper = resolve(),
            walletIdentifierValidation: @escaping WalletValidation = walletIdentifierValidator
        ) {
            self.mainQueue = mainQueue
            self.sessionTokenService = sessionTokenService
            self.loginService = loginService
            self.wallet = wallet
            self.featureFlags = featureFlags
            self.walletIdentifierValidation = walletIdentifierValidation
        }
    }
}

let manualPairingReducer = Reducer.combine(
    passwordReducer
        .pullback(
            state: \ManualPairing.State.passwordState,
            action: /ManualPairing.Action.password,
            environment: { _ in PasswordEnvironment() }
        ),
    Reducer<
        ManualPairing.State,
        ManualPairing.Action,
        ManualPairing.Environment
    > { state, action, environment in
        switch action {
        case .continue:
            state.isLoggingIn = true
            return environment
                .sessionTokenService
                .setupSessionTokenPublisher()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: ManualPairing.Cancelations.SessionTokenId(), cancelInFlight: true)
                .map { result -> ManualPairing.Action in
                    if case .failure(let error) = result {
                        return .alert(.show(title: "Session Token Error", message: error.localizedDescription))
                    }
                    return .login
                }
        case .login:
            let password = state.passwordState.password
            return environment.loginService
                .loginPublisher(walletIdentifier: state.walletIdentifier)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: ManualPairing.Cancelations.LoginId(), cancelInFlight: true)
                .map { result -> ManualPairing.Action in
                    if case .failure(let error) = result {
                        return .alert(.show(title: "Login error", message: error.localizedDescription))
                    }
                    return .authenticate(password: password)
                }
        case .authenticate:
            // should be handled in CoreCoordinator
            return .merge(
                .cancel(id: ManualPairing.Cancelations.SessionTokenId()),
                .cancel(id: ManualPairing.Cancelations.LoginId())
            )
        case .walletIdentifier(let guid):
            state.walletIdentifier = guid
            guard !guid.isEmpty else {
                state.incorrectWalletIdentifier = false
                return .none
            }
            state.incorrectWalletIdentifier = !environment.walletIdentifierValidation(guid)
            return .none
        case .password(.incorrectPasswordErrorVisibility(let isVisible)):
            return .none
        case .password:
            return .none
        case .closeButtonTapped:
            return .merge(
                .cancel(id: ManualPairing.Cancelations.SessionTokenId()),
                .cancel(id: ManualPairing.Cancelations.LoginId())
            )
        case .alert(.show(let title, let message)):
            state.isLoggingIn = false
            state.alertState = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    send: .alert(.dismiss)
                )
            )
            return .merge(
                .cancel(id: ManualPairing.Cancelations.SessionTokenId()),
                .cancel(id: ManualPairing.Cancelations.LoginId())
            )
        case .alert(.dismiss):
            state.alertState = nil
            return .none
        case .none:
            return .none
        }
    }
)

func walletIdentifierValidator(_ value: String) -> Bool {
    value.range(of: TextRegex.walletIdentifier.rawValue, options: .regularExpression) != nil
}

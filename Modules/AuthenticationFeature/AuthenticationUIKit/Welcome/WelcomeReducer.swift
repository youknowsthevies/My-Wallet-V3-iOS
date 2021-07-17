// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum WelcomeAction: Equatable {
    case start
    case presentScreenFlow(WelcomeState.ScreenFlow)
    case emailLogin(EmailLoginAction)
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable {
    public enum ScreenFlow {
        case welcomeScreen
        case createWalletScreen
        case emailLoginScreen
        case recoverWalletScreen
    }

    public var screenFlow: ScreenFlow
    public var buildVersion: String
    var emailLoginState: EmailLoginState?

    public init() {
        emailLoginState = .init()
        buildVersion = ""
        screenFlow = .welcomeScreen
    }
}

public struct WelcomeEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let buildVersionProvider: () -> String

    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                buildVersionProvider: @escaping () -> String) {
        self.mainQueue = mainQueue
        self.buildVersionProvider = buildVersionProvider
    }
}

public let welcomeReducer = Reducer.combine(
    emailLoginReducer
        .optional()
        .pullback(
            state: \.emailLoginState,
            action: /WelcomeAction.emailLogin,
            environment: { _ in EmailLoginEnvironment() }
        ),
    Reducer<
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
    > { state, action, environment in
        switch action {
        case .start:
            state.buildVersion = environment.buildVersionProvider()
            return .none
        case let .presentScreenFlow(screenFlow):
            state.screenFlow = screenFlow
            return .none
        case .emailLogin(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.emailLoginState = .init()
            return .none
        case .emailLogin:
            // handled in email login reducer
            return .none
        }
    }
)

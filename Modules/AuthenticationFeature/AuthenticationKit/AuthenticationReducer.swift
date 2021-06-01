// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public let authenticationReducer = Reducer<AuthenticationState, AuthenticationAction, AuthenticationEnvironment> { state, action, environment in
    switch action {
    case .createWallet:
        return .none
    case .login:
        return .none
    case .recoverFunds:
        return .none
    case .setLoginVisible(let isVisible):
        state.isLoginVisible = isVisible
        return .none
    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        return .none
    }
}

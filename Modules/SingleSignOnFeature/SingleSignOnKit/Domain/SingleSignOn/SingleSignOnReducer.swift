// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public let singleSignOnReducer = Reducer<SingleSignOnState, SingleSignOnAction, SingleSignOnEnvironment> { state, action, environment in
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
    }
}

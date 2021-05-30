// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let signleSignOnReducer = Reducer<SingleSignOnState, SingleSignOnAction, SingleSignOnEnvironment> { state, action, environment in
    switch action {
    case .createWallet:
        return .none
    case .login:
        return .none
    case .recoverFunds:
        return .none
    }
}

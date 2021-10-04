// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let tourReducer = Reducer<TourState, TourAction, TourEnvironment> { _, action, environment in
    switch action {
    case .createAccount:
        environment.createAccountAction()
        return .none
    case .restore:
        environment.restoreAction()
        return .none
    case .logIn:
        environment.logInAction()
        return .none
    }
}

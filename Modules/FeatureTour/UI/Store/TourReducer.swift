// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let tourReducer = Reducer<TourState, TourAction, TourEnvironment> { _, action, _ in
    switch action {
    case .createAccount:
        return .none
    case .restore:
        return .none
    case .logIn:
        return .none
    }
}

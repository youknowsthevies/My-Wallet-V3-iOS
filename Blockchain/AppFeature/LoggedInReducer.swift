// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum LoggedIn {
    public enum Action: Equatable {
        case none
    }

    public struct State: Equatable {

    }

    public struct Environment {

    }
}

let loggedInReducer = Reducer<LoggedIn.State, LoggedIn.Action, LoggedIn.Environment> { _, action, _ in
    switch action {
    case .none:
        return .none
    }
}

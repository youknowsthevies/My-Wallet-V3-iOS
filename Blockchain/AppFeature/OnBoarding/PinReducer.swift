// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture

public enum PinCore {
    public enum Action: Equatable {
        case authenticate
        case create
        case change
        case logout
        case handleAuthentication(_ password: String)
    }
    
    public struct State: Equatable {
        var creating: Bool = false
        var authenticate: Bool = false
    }

    public struct Environment {
        let walletManager: WalletManager
    }
}

let pinReducer = Reducer<PinCore.State, PinCore.Action, PinCore.Environment> { state, action, environment in
    switch action {
    case .authenticate:
        state.creating = false
        state.authenticate = true
        return .none
    case .create:
        state.creating = true
        state.authenticate = false
        return .none
    case .change:
        return .none
    case .logout:
        return .none
    case .handleAuthentication(let password):
        return .none
    }
}

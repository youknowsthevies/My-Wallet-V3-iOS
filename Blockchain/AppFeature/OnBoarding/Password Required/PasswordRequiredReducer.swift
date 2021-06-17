// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum PasswordRequired {
    public enum Action: Equatable {
        case start
        case authenticate(String)
        case forgetWallet
    }

    /// intentionally left empty
    public struct State: Equatable {}
    /// intentionally left empty
    public struct Environment {}
}

/// This is tiny, :apologies:, the logic can be extracted out of the Interactor/Presenter of the current PasswordRequired implementation
/// but having this here might force us to refactor the current implementation.
let passwordRequiredReducer = Reducer<PasswordRequired.State, PasswordRequired.Action, PasswordRequired.Environment> { _, action, _ in
    switch action {
    case .start:
        return .none
    case .authenticate:
        return .none
    case .forgetWallet:
        return .none
    }
}

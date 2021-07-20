// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum PasswordAction: Equatable {
    case didChangePassword(String)
    case incorrectPasswordErrorVisibility(Bool)
}

// MARK: - Properties

struct PasswordState: Equatable {
    var password: String
    var isPasswordIncorrect: Bool

    init() {
        password = ""
        isPasswordIncorrect = false
    }
}

let passwordReducer = Reducer<
    PasswordState,
    PasswordAction,
    CredentialsEnvironment
> {
    state, action, environment in
    switch action {
    case let .didChangePassword(password):
        state.password = password
        return .none
    case let .incorrectPasswordErrorVisibility(isVisible):
        state.isPasswordIncorrect = isVisible
        return .none
    }
}

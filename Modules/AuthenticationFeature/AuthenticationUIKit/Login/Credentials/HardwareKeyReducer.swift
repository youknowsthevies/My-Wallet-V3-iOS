// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum HardwareKeyAction: Equatable {
    case didChangeHardwareKeyCode(String)
    case hardwareKeyCodeFieldVisibility(Bool)
    case incorrectHardwareKeyCodeErrorVisibility(Bool)
}

// MARK: - Properties

struct HardwareKeyState: Equatable {
    var hardwareKeyCode: String = ""
    var isHardwareKeyCodeFieldVisible = false
    var isHardwareKeyCodeIncorrect: Bool = false
}

let hardwareKeyReducer = Reducer<
    HardwareKeyState,
    HardwareKeyAction,
    CredentialsEnvironment
> {
    state, action, environmnet in
    switch action {
    case let .didChangeHardwareKeyCode(code):
        state.hardwareKeyCode = code
        return .none
    case let .hardwareKeyCodeFieldVisibility(isVisible):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = isVisible
        return .none
    case let .incorrectHardwareKeyCodeErrorVisibility(isVisible):
        state.isHardwareKeyCodeIncorrect = isVisible
        return .none
    }
}

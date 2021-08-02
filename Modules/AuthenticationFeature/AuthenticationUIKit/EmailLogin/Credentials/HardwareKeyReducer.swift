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
    state, action, _ in
    switch action {
    case .didChangeHardwareKeyCode(let code):
        state.hardwareKeyCode = code
        return .none
    case .hardwareKeyCodeFieldVisibility(let isVisible):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = isVisible
        return .none
    case .incorrectHardwareKeyCodeErrorVisibility(let isVisible):
        state.isHardwareKeyCodeIncorrect = isVisible
        return .none
    }
}

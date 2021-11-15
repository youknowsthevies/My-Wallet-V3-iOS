// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum HardwareKeyAction: Equatable {
    case didChangeHardwareKeyCode(String)
    case showHardwareKeyCodeField(Bool)
    case showIncorrectHardwareKeyCodeError(Bool)
}

// MARK: - Properties

struct HardwareKeyState: Equatable {
    var hardwareKeyCode: String
    var isHardwareKeyCodeFieldVisible: Bool
    var isHardwareKeyCodeIncorrect: Bool

    init(
        hardwareKeyCode: String = "",
        isHardwareKeyCodeFieldVisible: Bool = false,
        isHardwareKeyCodeIncorrect: Bool = false
    ) {
        self.hardwareKeyCode = hardwareKeyCode
        self.isHardwareKeyCodeIncorrect = isHardwareKeyCodeIncorrect
        self.isHardwareKeyCodeFieldVisible = isHardwareKeyCodeFieldVisible
    }
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
    case .showHardwareKeyCodeField(let shouldShow):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = shouldShow
        return .none
    case .showIncorrectHardwareKeyCodeError(let shouldShow):
        state.isHardwareKeyCodeIncorrect = shouldShow
        return .none
    }
}

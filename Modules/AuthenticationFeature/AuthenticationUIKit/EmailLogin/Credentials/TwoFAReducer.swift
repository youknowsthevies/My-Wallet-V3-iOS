// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum TwoFAAction: Equatable {
    case didChangeTwoFACode(String)
    case didChangeTwoFACodeAttemptsLeft(Int)
    case incorrectTwoFACodeErrorVisibility(Bool)
    case resendSMSButtonVisibility(Bool)
    case twoFACodeFieldVisibility(Bool)
}

private enum Constants {
    static let twoFACodeMaxAttemptsLeft = 5
}

// MARK: - Properties

struct TwoFAState: Equatable {
    var twoFACode: String
    var isTwoFACodeFieldVisible: Bool
    var isResendSMSButtonVisible: Bool
    var isTwoFACodeIncorrect: Bool
    var twoFACodeAttemptsLeft: Int

    init() {
        twoFACode = ""
        isTwoFACodeFieldVisible = false
        isResendSMSButtonVisible = false
        isTwoFACodeIncorrect = false
        twoFACodeAttemptsLeft = Constants.twoFACodeMaxAttemptsLeft
    }
}

let twoFAReducer = Reducer<
    TwoFAState,
    TwoFAAction,
    CredentialsEnvironment
> { state, action, environment in
    switch action {
    case let .didChangeTwoFACode(code):
        state.twoFACode = code
        return .none
    case let .didChangeTwoFACodeAttemptsLeft(attemptsLeft):
        state.twoFACodeAttemptsLeft = attemptsLeft
        return Effect(value: .incorrectTwoFACodeErrorVisibility(true))
    case let .incorrectTwoFACodeErrorVisibility(isVisible):
        state.isTwoFACodeIncorrect = isVisible
        return .none
    case let .resendSMSButtonVisibility(isVisible):
        state.isResendSMSButtonVisible = isVisible
        return .none
    case let .twoFACodeFieldVisibility(isVisible):
        state.twoFACode = ""
        state.isTwoFACodeFieldVisible = isVisible
        return .none
    }
}

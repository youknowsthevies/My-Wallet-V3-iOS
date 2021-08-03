// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformUIKit

// MARK: - Type

enum ResetPasswordContext {
    case mandatory
    case optional
    case none
}

public enum ResetPasswordAction: Equatable {
    case didDisappear
    case didChangeNewPassword(String)
    case didChangeConfirmNewPassword(String)
    case didChangePasswordStrength(PasswordValidationScore)
    case validatePasswordStrength
    case none
}

// MARK: - Properties

struct ResetPasswordState: Equatable {
    var newPassword: String
    var confirmNewPassword: String
    var passwordStrength: PasswordValidationScore

    init() {
        newPassword = ""
        confirmNewPassword = ""
        passwordStrength = .none
    }
}

struct ResetPasswordEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        passwordValidator: PasswordValidatorAPI = PasswordValidator()
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
    }
}

let resetPasswordReducer = Reducer<
    ResetPasswordState,
    ResetPasswordAction,
    ResetPasswordEnvironment
> { state, action, environment in
    switch action {

    case .didDisappear:
        // clear states after disappear
        state.newPassword = ""
        state.confirmNewPassword = ""
        state.passwordStrength = .none
        return .none

    case .didChangeNewPassword(let password):
        state.newPassword = password
        return .none
    case .didChangeConfirmNewPassword(let password):
        state.confirmNewPassword = password
        return .none
    case .didChangePasswordStrength(let score):
        state.passwordStrength = score
        return .none
    case .validatePasswordStrength:
        return environment
            .passwordValidator
            .validate(password: state.newPassword)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> ResetPasswordAction in
                guard case .success(let score) = result else {
                    return .none
                }
                return .didChangePasswordStrength(score)
            }
    case .none:
        return .none
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum CreateAccountAction: Equatable {
    case onWillDisappear
    case closeButtonTapped
    case didChangeEmailAddress(String)
    case didChangePassword(String)
    case didChangeConfirmPassword(String)
    case didChangePasswordStrength(PasswordValidationScore)
    case validatePasswordStrength
    case openExternalLink(URL)
    case createButtonTapped(String, String)
    case noop
}

// MARK: - Properties

public struct CreateAccountState: Equatable {
    var isImportWallet: Bool
    var emailAddress: String
    var password: String
    var confirmPassword: String
    var passwordStrength: PasswordValidationScore

    init(isImportWallet: Bool) {
        self.isImportWallet = isImportWallet
        emailAddress = ""
        password = ""
        confirmPassword = ""
        passwordStrength = .none
    }
}

struct CreateAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        passwordValidator: PasswordValidatorAPI = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
    }
}

let createAccountReducer = Reducer<
    CreateAccountState,
    CreateAccountAction,
    CreateAccountEnvironment
> { state, action, environment in
    switch action {
    case .onWillDisappear:
        return .none
    case .closeButtonTapped:
        return .none
    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        return .none
    case .didChangePassword(let password):
        state.password = password
        return Effect(value: .validatePasswordStrength)
    case .didChangeConfirmPassword(let password):
        state.confirmPassword = password
        return .none
    case .didChangePasswordStrength(let score):
        state.passwordStrength = score
        return .none
    case .validatePasswordStrength:
        return environment
            .passwordValidator
            .validate(password: state.password)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CreateAccountAction in
                guard case .success(let score) = result else {
                    return .didChangePasswordStrength(.none)
                }
                return .didChangePasswordStrength(score)
            }
    case .openExternalLink(let url):
        environment.externalAppOpener.open(url)
        return .none
    case .createButtonTapped:
        return .none
    case .noop:
        return .none
    }
}
.analytics()

// MARK: - Private

extension Reducer where
    Action == CreateAccountAction,
    State == CreateAccountState,
    Environment == CreateAccountEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CreateAccountState,
                CreateAccountAction,
                CreateAccountEnvironment
            > { state, action, environment in
                switch action {
                case .onWillDisappear:
                    if state.isImportWallet {
                        environment.analyticsRecorder.record(
                            event: .importWalletCancelled
                        )
                    }
                    return .none
                case .createButtonTapped:
                    if state.isImportWallet {
                        environment.analyticsRecorder.record(
                            event: .importWalletConfirmed
                        )
                    }
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}

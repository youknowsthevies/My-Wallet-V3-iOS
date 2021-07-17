// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import DIKit
import Localization

// MARK: - Type

public enum EmailLoginAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }
    case closeButtonTapped
    case didDisappear
    case didChangeEmailAddress(String)
    case didSendVerifyDeviceEmail(Result<Int, AuthenticationServiceError>)
    case emailLoginFailureAlert(AlertAction)
    case sendVerifyDeviceEmail
    case setVerifyDeviceScreenVisible(Bool)
    case verifyDevice(VerifyDeviceAction)
}

// MARK: - Properties

struct EmailLoginState: Equatable {
    var emailAddress: String
    var isEmailValid: Bool
    var isVerifyDeviceScreenVisible: Bool
    var verifyDeviceState: VerifyDeviceState?
    var emailLoginFailureAlert: AlertState<EmailLoginAction>?

    init() {
        verifyDeviceState = .init()
        emailAddress = ""
        isEmailValid = false
        isVerifyDeviceScreenVisible = false
    }
}

struct EmailLoginEnvironment {
    let authenticationService: AuthenticationServiceAPI
    let recaptchaService: GoogleRecaptchaServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateEmail: (String) -> Bool = { $0.isEmail }

    init(authenticationService: AuthenticationServiceAPI = resolve(),
         recaptchaService: GoogleRecaptchaServiceAPI = resolve(),
         mainQueue: AnySchedulerOf<DispatchQueue> = .main) {
        self.authenticationService = authenticationService
        self.recaptchaService = recaptchaService
        self.mainQueue = mainQueue
    }
}

let emailLoginReducer = Reducer.combine(
    verifyDeviceReducer
        .optional()
        .pullback(
        state: \.verifyDeviceState,
        action: /EmailLoginAction.verifyDevice,
        environment: { _ in VerifyDeviceEnvironment() }
    ),
    Reducer<EmailLoginState, EmailLoginAction, EmailLoginEnvironment> { state, action, environment in
        switch action {
        case .closeButtonTapped:
            // handled in welcome reducer
            return .none

        case .didDisappear:
            state.emailAddress = ""
            state.isEmailValid = false
            state.emailLoginFailureAlert = nil
            return .none

        case let .didChangeEmailAddress(emailAddress):
            state.emailAddress = emailAddress
            state.isEmailValid = environment.validateEmail(emailAddress)
            return .none

        case let .didSendVerifyDeviceEmail(response):
            if case let .failure(error) = response {
                switch error {
                case .recaptchaError, .missingSessionToken:
                    return Effect(value: .emailLoginFailureAlert(.show(title: "", message: "")))
                case .networkError:
                    break
                }
            }
            return Effect(value: .setVerifyDeviceScreenVisible(true))

        case let .emailLoginFailureAlert(.show(title, message)):
            state.emailLoginFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    send: .emailLoginFailureAlert(.dismiss)
                )
            )
            return .none

        case .emailLoginFailureAlert(.dismiss):
            state.emailLoginFailureAlert = nil
            return .none

        case .sendVerifyDeviceEmail,
             .verifyDevice(.sendDeviceVerificationEmail):
            guard state.isEmailValid else {
                return .none
            }
            return environment
                .authenticationService
                .sendDeviceVerificationEmail(to: state.emailAddress)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> EmailLoginAction in
                    switch result {
                    case .success:
                        return .didSendVerifyDeviceEmail(.success((0)))
                    case let .failure(error):
                        return .didSendVerifyDeviceEmail(.failure(error))
                    }
                }

        case let .setVerifyDeviceScreenVisible(isVisible):
            state.isVerifyDeviceScreenVisible = isVisible
            return .none

        case .verifyDevice(.didExtractWalletInfo),
             .verifyDevice(.didReceiveWalletInfoDeeplink),
             .verifyDevice(.verifyDeviceFailureAlert),
             .verifyDevice(.credentials),
             .verifyDevice(.setCredentialsScreenVisible),
             .verifyDevice(.didDisappear):
            // handled in verify device reducer
            return .none
        }
    }
)

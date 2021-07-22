// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import DIKit
import Localization
import ToolKit

// MARK: - Type

public enum EmailLoginAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case closeButtonTapped
    case didDisappear
    case didChangeEmailAddress(String)
    case didSendDeviceVerificationEmail(Result<EmptyValue, DeviceVerificationServiceError>)
    case emailLoginFailureAlert(AlertAction)
    case sendDeviceVerificationEmail
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
    let deviceVerificationService: DeviceVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateEmail: (String) -> Bool

    init(
        deviceVerificationService: DeviceVerificationServiceAPI,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        validateEmail: @escaping (String) -> Bool = { $0.isEmail }
    ) {
        self.deviceVerificationService = deviceVerificationService
        self.mainQueue = mainQueue
        self.validateEmail = validateEmail
    }
}

let emailLoginReducer = Reducer.combine(
    verifyDeviceReducer
        .optional()
        .pullback(
            state: \.verifyDeviceState,
            action: /EmailLoginAction.verifyDevice,
            environment: {
                VerifyDeviceEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService
                )
            }
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

        case .didChangeEmailAddress(let emailAddress):
            state.emailAddress = emailAddress
            state.isEmailValid = environment.validateEmail(emailAddress)
            return .none

        case .didSendDeviceVerificationEmail(let response):
            if case .failure(let error) = response {
                switch error {
                case .recaptchaError:
                    return Effect(value: .emailLoginFailureAlert(.show(title: "Recaptcha Error", message: error.localizedDescription)))
                case .missingSessionToken:
                    return Effect(value: .emailLoginFailureAlert(.show(title: "Missing Session Token", message: error.localizedDescription)))
                case .networkError:
                    // still go to verify device screen if there is network error
                    break
                }
            }
            return Effect(value: .setVerifyDeviceScreenVisible(true))

        case .emailLoginFailureAlert(.show(let title, let message)):
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

        case .sendDeviceVerificationEmail,
             .verifyDevice(.sendDeviceVerificationEmail):
            guard state.isEmailValid else {
                return .none
            }
            return environment
                .deviceVerificationService
                .sendDeviceVerificationEmail(to: state.emailAddress)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> EmailLoginAction in
                    switch result {
                    case .success:
                        return .didSendDeviceVerificationEmail(.success(.noValue))
                    case .failure(let error):
                        return .didSendDeviceVerificationEmail(.failure(error))
                    }
                }

        case .setVerifyDeviceScreenVisible(let isVisible):
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

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import ComposableArchitecture
import DIKit
import Localization
import ToolKit

// MARK: - Type

public enum VerifyDeviceAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case credentials(CredentialsAction)
    case didDisappear
    case fallbackToWalletIdentifier
    case didExtractWalletInfo(WalletInfo)
    case didReceiveWalletInfoDeeplink(URL)
    case sendDeviceVerificationEmail
    case setCredentialsScreenVisible(Bool)
    case verifyDeviceFailureAlert(AlertAction)
    case none
}

// MARK: - Properties

struct VerifyDeviceState: Equatable {
    var isCredentialsScreenVisible: Bool
    var credentialsContext: CredentialsContext
    var credentialsState: CredentialsState?
    var verifyDeviceFailureAlert: AlertState<VerifyDeviceAction>?
    var emailAddress: String
    var sendEmailButtonIsLoading: Bool

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        credentialsState = .init()
        isCredentialsScreenVisible = false
        credentialsContext = .none
        sendEmailButtonIsLoading = false
    }
}

struct VerifyDeviceEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording = resolve()
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
    }
}

let verifyDeviceReducer = Reducer.combine(
    credentialsReducer
        .optional()
        .pullback(
            state: \.credentialsState,
            action: /VerifyDeviceAction.credentials,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    Reducer<
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    > { state, action, environment in
        switch action {
        case .didDisappear:
            state.verifyDeviceFailureAlert = nil
            return .none

        case .credentials:
            // handled in credentials reducer
            return .none

        case .didExtractWalletInfo(let walletInfo):
            state.credentialsState = .init()
            state.credentialsContext = .walletInfo(walletInfo)
            return Effect(value: .setCredentialsScreenVisible(true))

        case .fallbackToWalletIdentifier:
            state.credentialsState = .init()
            state.credentialsContext = .walletIdentifier(email: state.emailAddress)
            return Effect(value: .setCredentialsScreenVisible(true))

        case .didReceiveWalletInfoDeeplink(let url):
            return environment
                .deviceVerificationService
                .extractWalletInfoFromDeeplink(url: url)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> VerifyDeviceAction in
                    switch result {
                    case .success(let walletInfo):
                        return .didExtractWalletInfo(walletInfo)
                    case .failure(let error):
                        environment.errorRecorder.error(error)
                        return .fallbackToWalletIdentifier
                    }
                }

        case .sendDeviceVerificationEmail:
            // handled in email login reducer
            return .none

        case .setCredentialsScreenVisible(let isVisible):
            state.isCredentialsScreenVisible = isVisible
            return .none

        case .verifyDeviceFailureAlert(.show(let title, let message)):
            state.verifyDeviceFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    send: .verifyDeviceFailureAlert(.dismiss)
                )
            )
            return .none

        case .verifyDeviceFailureAlert(.dismiss):
            state.verifyDeviceFailureAlert = nil
            return .none
        case .none:
            return .none
        }
    }
)

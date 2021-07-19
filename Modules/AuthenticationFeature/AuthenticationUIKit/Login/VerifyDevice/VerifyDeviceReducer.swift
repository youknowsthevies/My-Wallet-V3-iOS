// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
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
    case didExtractWalletInfo(WalletInfo)
    case didReceiveWalletInfoDeeplink(URL)
    case sendDeviceVerificationEmail
    case setCredentialsScreenVisible(Bool)
    case verifyDeviceFailureAlert(AlertAction)
}

// MARK: - Properties

struct VerifyDeviceState: Equatable {
    var isCredentialsScreenVisible: Bool
    var walletInfo: WalletInfo
    var credentialsState: CredentialsState?
    var verifyDeviceFailureAlert: AlertState<VerifyDeviceAction>?

    init() {
        credentialsState = .init()
        isCredentialsScreenVisible = false
        walletInfo = WalletInfo.empty
    }
}

struct VerifyDeviceEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording

    init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
         deviceVerificationService: DeviceVerificationServiceAPI,
         errorRecorder: ErrorRecording = resolve()) {
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

        case let .didExtractWalletInfo(walletInfo):
            state.walletInfo = walletInfo
            return Effect(value: .setCredentialsScreenVisible(true))

        case let .didReceiveWalletInfoDeeplink(url):
            return environment
                .deviceVerificationService
                .extractWalletInfoFromDeeplink(url: url)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> VerifyDeviceAction in
                    switch result {
                    case let .success(walletInfo):
                        return .didExtractWalletInfo(walletInfo)
                    case .failure(let error):
                        environment.errorRecorder.error(error)
                        return .verifyDeviceFailureAlert(.show(title: "", message: ""))
                    }
                }

        case .sendDeviceVerificationEmail:
            // handled in email login reducer
            return .none

        case let .setCredentialsScreenVisible(isVisible):
            state.isCredentialsScreenVisible = isVisible
            return .none

        case let .verifyDeviceFailureAlert(.show(title, message)):
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
        }
    }
)

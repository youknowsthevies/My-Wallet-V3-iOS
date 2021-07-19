// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AuthenticationKit
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

// MARK: - Type

public enum CredentialsAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }
    public enum WalletPairingAction: Equatable {
        case approveEmailAuthorization
        case authenticate
        case authenticateWithTwoFAOrHardwareKey
        case decryptWalletWithPassword(String)
        case pollWalletIdentifier
        case requestSMSCode
        case setupSessionToken
    }
    case didAppear(walletInfo: WalletInfo)
    case didDisappear
    case password(PasswordAction)
    case twoFA(TwoFAAction)
    case hardwareKey(HardwareKeyAction)
    case walletPairing(WalletPairingAction)
    case setTwoFAOrHardwareKeyVerified(Bool)
    case accountLockedErrorVisibility(Bool)
    case credentialsFailureAlert(AlertAction)
    case none
}

// MARK: - Properties

enum WalletPairingCancelations {
    struct WalletIdentifierPollingTimerId: Hashable {}
    struct WalletIdentifierPollingId: Hashable {}
}

struct CredentialsState: Equatable {
    var passwordState: PasswordState?
    var twoFAState: TwoFAState?
    var hardwareKeyState: HardwareKeyState?
    var emailAddress: String
    var walletGuid: String
    var emailCode: String
    var isTwoFACodeOrHardwareKeyVerified: Bool
    var isAccountLocked: Bool
    var credentialsFailureAlert: AlertState<CredentialsAction>?

    init() {
        passwordState = .init()
        twoFAState = .init()
        hardwareKeyState = .init()
        emailAddress = ""
        walletGuid = ""
        emailCode = ""
        isTwoFACodeOrHardwareKeyVerified = false
        isAccountLocked = false
    }
}

struct CredentialsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let sessionTokenService: SessionTokenServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let wallet: WalletAuthenticationKitWrapper
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let errorRecorder: ErrorRecording

    init(mainQueue: AnySchedulerOf<DispatchQueue> = .main,
         pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.blockchain.AuthenticationEnvironmentPollingQueue",
            qos: .utility
         ).eraseToAnyScheduler(),
         deviceVerificationService: DeviceVerificationServiceAPI,
         emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
         sessionTokenService: SessionTokenServiceAPI = resolve(),
         smsService: SMSServiceAPI = resolve(),
         loginService: LoginServiceAPI = resolve(),
         wallet: WalletAuthenticationKitWrapper = resolve(),
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
         errorRecorder: ErrorRecording) {

        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.deviceVerificationService = deviceVerificationService
        self.emailAuthorizationService = emailAuthorizationService
        self.sessionTokenService = sessionTokenService
        self.smsService = smsService
        self.loginService = loginService
        self.wallet = wallet
        self.analyticsRecorder = analyticsRecorder
        self.errorRecorder = errorRecorder
    }
}

let credentialsReducer = Reducer.combine(
    passwordReducer
        .optional()
        .pullback(
        state: \CredentialsState.passwordState,
        action: /CredentialsAction.password,
        environment: { $0 }
    ),
    twoFAReducer
        .optional()
        .pullback(
        state: \CredentialsState.twoFAState,
        action: /CredentialsAction.twoFA,
        environment: { $0 }
    ),
    hardwareKeyReducer
        .optional()
        .pullback(
        state: \CredentialsState.hardwareKeyState,
        action: /CredentialsAction.hardwareKey,
        environment: { $0 }
    ),
    Reducer<
        CredentialsState,
        CredentialsAction,
        CredentialsEnvironment
    > { state, action, environment in
        switch action {
        case let .didAppear(walletInfo):
            state.emailAddress = walletInfo.email
            state.walletGuid = walletInfo.guid
            state.emailCode = walletInfo.emailCode
            return Effect(value: .walletPairing(.setupSessionToken))

        case .didDisappear:
            state.emailAddress = ""
            state.walletGuid = ""
            state.emailCode = ""
            state.isTwoFACodeOrHardwareKeyVerified = false
            state.isAccountLocked = false
            state.passwordState = nil
            state.twoFAState = nil
            state.hardwareKeyState = nil
            return .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId())

        case .password, .twoFA, .hardwareKey:
            // handled in respective reducers
            return .none

        case let .walletPairing(action):
            switch action {
            case .approveEmailAuthorization:
                guard !state.emailCode.isEmpty else {
                    fatalError("Email code should not be empty")
                }
                return .merge(
                    // Poll the Guid every 2 seconds
                    Effect
                        .timer(
                            id: WalletPairingCancelations.WalletIdentifierPollingTimerId(),
                            every: 2,
                            on: environment.pollingQueue
                        )
                        .map { _ in .walletPairing(.pollWalletIdentifier) },
                    // Immediately authorize the email
                    environment
                        .deviceVerificationService
                        .authorizeLogin(emailCode: state.emailCode)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { result -> CredentialsAction in
                            if case let .failure(error) = result {
                                // If failed, an `Authorize Log In` will be sent to user for manual authorization
                                environment.errorRecorder.error(error)
                            }
                            return .none
                        }
                )
            case .authenticate:
                guard !state.walletGuid.isEmpty else {
                    fatalError("GUID should not be empty")
                }
                guard let passwordState = state.passwordState,
                      let twoFAState = state.twoFAState,
                      let hardwareKeyState = state.hardwareKeyState else {
                    fatalError("States should not be nil")
                }
                return .merge(
                    // Clear error states
                    Effect(value: .accountLockedErrorVisibility(false)),
                    Effect(value: .password(.incorrectPasswordErrorVisibility(false))),
                    .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId()),
                    environment
                        .loginService
                        .loginPublisher(walletIdentifier: state.walletGuid)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { result -> CredentialsAction in
                            switch result {
                            case .success:
                                return .walletPairing(.decryptWalletWithPassword(passwordState.password))
                            case let .failure(error):
                                switch error {
                                case .twoFactorOTPRequired(let type):
                                    if twoFAState.isTwoFACodeFieldVisible ||
                                        hardwareKeyState.isHardwareKeyCodeFieldVisible {
                                        return .walletPairing(.authenticateWithTwoFAOrHardwareKey)
                                    }
                                    switch type {
                                    case .email:
                                        return .walletPairing(.approveEmailAuthorization)
                                    case .sms:
                                        return .walletPairing(.requestSMSCode)
                                    case .google:
                                        return .twoFA(.twoFACodeFieldVisibility(true))
                                    case .yubiKey, .yubikeyMtGox:
                                        return .hardwareKey(.hardwareKeyCodeFieldVisibility(true))
                                    default:
                                        fatalError("Unsupported TwoFA Types")
                                    }
                                case .walletPayloadServiceError(.accountLocked):
                                    return .accountLockedErrorVisibility(true)
                                case .walletPayloadServiceError(let error):
                                    // TODO: Await design for error state
                                    environment.errorRecorder.error(error)
                                    return .credentialsFailureAlert(.show(title: "", message: ""))
                                case .twoFAWalletServiceError:
                                    fatalError("Shouldn't receive TwoFAService errors here")
                                }
                            }
                        }
                )

            case .authenticateWithTwoFAOrHardwareKey:
                guard !state.walletGuid.isEmpty else {
                    fatalError("GUID should not be empty")
                }
                guard let passwordState = state.passwordState,
                      let twoFAState = state.twoFAState,
                      let hardwareKeyState = state.hardwareKeyState else {
                    fatalError("States should not be nil")
                }
                return .merge(
                    // clear error states
                    Effect(value: .accountLockedErrorVisibility(false)),
                    Effect(value: .hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(false))),
                    Effect(value: .twoFA(.incorrectTwoFACodeErrorVisibility(false))),
                    Effect(value: .password(.incorrectPasswordErrorVisibility(false))),
                    environment
                        .loginService
                        .loginPublisher(walletIdentifier: state.walletGuid,
                                        code: twoFAState.twoFACode)
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { result -> CredentialsAction in
                            switch result {
                            case .success:
                                return .setTwoFAOrHardwareKeyVerified(true)
                            case .failure(let error):
                                switch error {
                                case .twoFAWalletServiceError(let error):
                                    switch error {
                                    case let .wrongCode(attemptsLeft):
                                        return .twoFA(.didChangeTwoFACodeAttemptsLeft(attemptsLeft))
                                    case .accountLocked:
                                        return .accountLockedErrorVisibility(true)
                                    case .missingCode:
                                        // TODO: Await design for error state
                                        return .credentialsFailureAlert(.show(title: "", message: ""))
                                    default:
                                        return .credentialsFailureAlert(.show(title: "", message: ""))
                                    }
                                case .walletPayloadServiceError:
                                    fatalError("Shouldn't receive WalletPayloadService errors here")
                                case .twoFactorOTPRequired:
                                    fatalError("Shouldn't receive twoFactorOTPRequired error here")
                                }
                            }
                        }
                )

            case .decryptWalletWithPassword:
                // handled in core coordinator
                return .none

            case .pollWalletIdentifier:
                return .concatenate(
                    .cancel(id: WalletPairingCancelations.WalletIdentifierPollingId()),
                    environment
                        .emailAuthorizationService
                        .authorizeEmailPublisher()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingId(), cancelInFlight: true)
                        .map { result -> CredentialsAction in
                            // Authenticate if the wallet identifier exists in repo
                            if case .success = result {
                                return .walletPairing(.authenticate)
                            }
                            return .none
                        }
                )
            case .requestSMSCode:
                return .merge(
                    Effect(value: .twoFA(.resendSMSButtonVisibility(true))),
                    Effect(value: .twoFA(.twoFACodeFieldVisibility(true))),
                    environment
                        .smsService
                        .requestPublisher()
                        .receive(on: environment.mainQueue)
                        .catchToEffect()
                        .map { result -> CredentialsAction in
                            switch result {
                            case .success:
                                // TODO: Await design for success state
                                return .credentialsFailureAlert(.show(title: "", message: ""))
                            case let .failure(error):
                                // TODO: Await design for error state
                                environment.errorRecorder.error(error)
                                return .credentialsFailureAlert(.show(title: "", message: ""))
                            }
                        }
                )
            case .setupSessionToken:
                return environment
                    .sessionTokenService
                    .setupSessionTokenPublisher()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        if case let .failure(error) = result {
                            // TODO: Await design for error state
                            environment.errorRecorder.error(error)
                            return .credentialsFailureAlert(.show(title: "", message: ""))
                        }
                        return .none
                    }
            }

        case let .setTwoFAOrHardwareKeyVerified(isVerified):
            guard let passwordState = state.passwordState else {
                fatalError("Password state should not be nil")
            }
            state.isTwoFACodeOrHardwareKeyVerified = isVerified
            switch isVerified {
            case true:
                return .merge(
                    Effect(value: .twoFA(.twoFACodeFieldVisibility(false))),
                    Effect(value: .hardwareKey(.hardwareKeyCodeFieldVisibility(false))),
                    Effect(value: .walletPairing(.decryptWalletWithPassword(passwordState.password)))
                )
            case false:
                return .none
            }

        case let .accountLockedErrorVisibility(isVisible):
            state.isAccountLocked = isVisible
            return .none

        case let .credentialsFailureAlert(.show(title, message)):
            state.credentialsFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    send: .credentialsFailureAlert(.dismiss)
                )
            )
            return .none

        case .credentialsFailureAlert(.dismiss):
            state.credentialsFailureAlert = nil
            return .none

        case .none:
            return .none
        }
    }
)

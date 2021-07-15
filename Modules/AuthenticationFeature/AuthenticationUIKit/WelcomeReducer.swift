// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AuthenticationKit
import Combine
import ComposableArchitecture
import ToolKit

private struct WelcomeCancelations {
    struct WalletIdentifierPollingTimerId: Hashable {}
    struct WalletIdentifierPollingId: Hashable {}
}

public let welcomeReducer = Reducer<
    WelcomeState,
    WelcomeAction,
    WelcomeEnvironment

    // swiftlint:disable closure_body_length
> { state, action, environment in
    struct TimerIdentifier: Hashable {}
    switch action {

    // MARK: - Start Action

    case .start:
        state.buildVersion = environment.buildVersionProvider()
        return .none

    // MARK: - Welcome Screen

    // TODO: Rename to create wallet in next PR
    case .createWallet:
        state.isLoginVisible = false
        return .none

    case .login:
        return .none

    case .recoverFunds:
        return .none

    // MARK: - Login Screen

    case .onLoginDisappear:
        // we need to clear the state of the login since it now happens on this state
        // There's a refactor on going that will make this obsolete
        state.isLoginVisible = false
        state.emailAddress = ""
        state.walletInfo = nil
        state.password = ""
        state.isPasswordIncorrect = false
        state.isVerifyDeviceVisible = false
        state.twoFACode = ""
        state.isTwoFACodeFieldVisible = false
        state.isTwoFACodeIncorrect = false
        state.isTwoFACodeVerified = false
        state.twoFACodeAttemptsLeft = 5
        state.isResendSMSButtonVisible = false
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = false
        state.isHardwareKeyCodeIncorrect = false
        state.isAccountLocked = false
        state.alert = nil
        return .none

    case .setLoginVisible(let isVisible):
        state.isLoginVisible = isVisible
        return .none

    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        return .none

    case .verifyRecaptcha:
        return environment
            .recaptchaService
            .verifyForLogin()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> WelcomeAction in
                switch result {
                case .success(let captcha):
                    return .verifyDevice(captcha)
                case .failure(let error):
                    // TODO: Replace alert state with inline error
                    environment.errorRecorder.error(error)
                    return .alert(.show(
                        title: "Recaptcha Failed",
                        message: error.localizedDescription
                    ))
                }
            }

    // MARK: - Verify Device Screen

    case .setVerifyDeviceVisible(let isVisible):
        state.isVerifyDeviceVisible = isVisible
        return .none

    case .verifyDevice(let captcha):
        return environment
            .authenticationService
            .sendDeviceVerificationEmail(to: state.emailAddress, captcha: captcha)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> WelcomeAction in
                if case .failure(let error) = result {
                    // For security purpose, users will not know if the email is successfully sent or not, just log the error
                    environment.errorRecorder.error(error)
                }
                return .setVerifyDeviceVisible(true)
            }

    case .didReceiveWalletInfoDeeplink(let url):
        return environment
            .authenticationService
            .extractWalletInfoFromDeeplink(url: url)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> WelcomeAction in
                switch result {
                case .success(let walletInfo):
                    return .didExtractWalletInfo(walletInfo)
                case .failure(let error):
                    // TODO: Accomodate for different accounts type in next PR
                    /*
                     https://blockc.slack.com/archives/C01TG37E3C6/p1625750495074000?thread_ts=1625749679.069500&cid=C01TG37E3C6
                     */
                    environment.errorRecorder.error(error)
                    return .alert(.show(
                        title: "Wallet Retrieval Failed",
                        message: error.localizedDescription
                    ))
                }
            }

    case .didExtractWalletInfo(let walletInfo):
        state.walletInfo = walletInfo
        return Effect(value: .setPasswordLoginVisible(true))

    // MARK: - Password Login Screen

    case .setPasswordLoginVisible(let isVisible):
        state.isPasswordLoginVisible = isVisible
        return Effect(value: .pairWallet)

    case .setHardwareKeyCodeFieldVisible(let isVisible):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = isVisible
        return .none

    case .setTwoFACodeFieldVisible(let isVisible):
        state.twoFACode = ""
        state.isTwoFACodeFieldVisible = isVisible
        return .none

    case .setResendSMSButtonVisible(let isVisible):
        state.isResendSMSButtonVisible = isVisible
        return .none

    case .didChangePassword(let password):
        state.password = password
        return .none

    case .didChangeTwoFACode(let code):
        state.twoFACode = code
        return .none

    case .didChangeHardwareKeyCode(let code):
        state.hardwareKeyCode = code
        return .none

    case .showIncorrectPasswordError(let isIncorrect):
        state.isPasswordIncorrect = isIncorrect
        return .none

    case .showIncorrectTwoFACodeError(let isIncorrect):
        state.isTwoFACodeIncorrect = isIncorrect
        return .none

    case .didChangeTwoFACodeAttemptsLeft(let attemptsLeft):
        state.twoFACodeAttemptsLeft = attemptsLeft
        return Effect(value: .showIncorrectTwoFACodeError(true))

    case .showIncorrectHardwareKeyCodeError(let isIncorrect):
        state.isHardwareKeyCodeIncorrect = isIncorrect
        return .none

    case .showAccountLockedError(let isLocked):
        state.isAccountLocked = isLocked
        return .none

    case .setTwoFACodeVerified(let isVerified):
        state.isTwoFACodeVerified = isVerified
        if isVerified {
            // Hide the 2FA Fields if already verified. Alternatively, we could show other success states
            // TODO: Await design for confirmation
            return .merge(
                Effect(value: .setTwoFACodeFieldVisible(false)),
                Effect(value: .setHardwareKeyCodeFieldVisible(false)),
                Effect(value: .authenticateWithPassword(state.password))
            )
        }
        return .none

    case .cancelPollingTimer:
        return .cancel(id: WelcomeCancelations.WalletIdentifierPollingTimerId())

    // MARK: - Wallet Decryption

    case .pairWallet:
        environment.walletPairingDependencies.wallet.loadJSIfNeeded()
        return environment
            .walletPairingDependencies
            .sessionTokenService
            .setupSessionTokenPublisher()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> WelcomeAction in
                if case let .failure(error) = result {
                    // TODO: Await design for error state
                    environment.errorRecorder.error(error)
                    return .alert(.show(
                        title: "Wallet Pairing Failed",
                        message: error.localizedDescription
                    ))
                }
                return .none
            }

    case .authenticate:
        guard let guid = state.walletInfo?.guid else {
            fatalError("Should have received guid when attemping to authenticate")
        }
        return .merge(
            // Clear error states
            Effect(value: .showAccountLockedError(false)),
            Effect(value: .showIncorrectPasswordError(false)),
            .cancel(id: WelcomeCancelations.WalletIdentifierPollingTimerId()),
            environment
                .walletPairingDependencies
                .loginService
                .loginPublisher(walletIdentifier: guid)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { [state] result -> WelcomeAction in
                    switch result {
                    case .success:
                        return .authenticateWithPassword(state.password)
                    case .failure(let error):
                        switch error {
                        case .twoFactorOTPRequired(let type):
                            if state.isTwoFACodeFieldVisible || state.isHardwareKeyCodeFieldVisible {
                                return .authenticateWithTwoFA
                            }
                            switch type {
                            case .email:
                                return .approveEmailAuthorization
                            case .sms:
                                return .requestOTPMessage
                            case .google:
                                return .setTwoFACodeFieldVisible(true)
                            case .yubiKey, .yubikeyMtGox:
                                return .setHardwareKeyCodeFieldVisible(true)
                            default:
                                fatalError("Unsupported TwoFA Types")
                            }
                        case .walletPayloadServiceError(.accountLocked):
                            return .showAccountLockedError(true)
                        case .walletPayloadServiceError(let error):
                            // TODO: Await design for error state
                            environment.errorRecorder.error(error)
                            return .alert(.show(title: "Authentication Failed", message: error.localizedDescription))
                        case .twoFAWalletServiceError:
                            fatalError("Shouldn't receive TwoFAService errors here")
                        }
                    }
                }
        )

    case .approveEmailAuthorization:
        guard let emailCode = state.walletInfo?.emailCode else {
            fatalError("Should have received email code when attemping to approve email authorization")
        }
        return .merge(
            // Poll the Guid every 2 seconds
            Effect
                .timer(id: TimerIdentifier(), every: 2, on: environment.pollingQueue)
                .cancellable(id: WelcomeCancelations.WalletIdentifierPollingTimerId(), cancelInFlight: true)
                .map { _ in .pollWalletIdentifier },
            // Immediately authorize the email
            environment
                .authenticationService
                .authorizeLogin(emailCode: emailCode)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> WelcomeAction in
                    if case let .failure(error) = result {
                        // If failed, an `Authorize Log In` will be sent to user for manual authorization
                        environment.errorRecorder.error(error)
                    }
                    return .none
                }
        )

    case .pollWalletIdentifier:
        return .concatenate(
            .cancel(id: WelcomeCancelations.WalletIdentifierPollingId()),
            environment
                .walletPairingDependencies
                .emailAuthorizationService
                .authorizeEmailPublisher()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WelcomeCancelations.WalletIdentifierPollingId(), cancelInFlight: true)
                .map { result -> WelcomeAction in
                    // Authenticate if the wallet identifier exists in repo
                    if case .success = result {
                        return .authenticate
                    }
                    return .none
                }
        )

    case .requestOTPMessage:
        return .merge(
            Effect(value: .setResendSMSButtonVisible(true)),
            Effect(value: .setTwoFACodeFieldVisible(true)),
            environment
                .walletPairingDependencies
                .smsService
                .requestPublisher()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> WelcomeAction in
                    switch result {
                    case .success:
                        // TODO: Await design for success state
                        return .alert(.show(
                            title: "OTP Requested",
                            message: "A one-time password has been sent to your mobile device via SMS."
                        ))
                    case .failure(let error):
                        // TODO: Await design for error state
                        environment.errorRecorder.error(error)
                        return .alert(.show(
                            title: "OTP Request Failed",
                            message: "Failed to send SMS"
                        ))
                    }
                }
        )

    case .authenticateWithTwoFA:
        guard let guid = state.walletInfo?.guid else {
            fatalError("Should have received guid when attemping to authenticate with 2FA")
        }
        return .merge(
            // clear error states
            Effect(value: .showAccountLockedError(false)),
            Effect(value: .showIncorrectHardwareKeyCodeError(false)),
            Effect(value: .showIncorrectTwoFACodeError(false)),
            Effect(value: .showIncorrectPasswordError(false)),
            environment
                .walletPairingDependencies
                .loginService
                .loginPublisher(walletIdentifier: guid,
                                code: state.twoFACode)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> WelcomeAction in
                    switch result {
                    case .success:
                        return .setTwoFACodeVerified(true)
                    case .failure(let error):
                        switch error {
                        case .twoFAWalletServiceError(let error):
                            switch error {
                            case .wrongCode(attemptsLeft: let attemptsLeft):
                                return .didChangeTwoFACodeAttemptsLeft(attemptsLeft)
                            case .accountLocked:
                                return .showAccountLockedError(true)
                            case .missingCode:
                                // TODO: Await design for error state
                                return .alert(.show(title: "Missing 2FA code", message: "Please make sure you have entered the 2FA code."))
                            default:
                                return .alert(.show(title: "2FA Authentication Failed", message: error.localizedDescription))
                            }
                        case .walletPayloadServiceError:
                            fatalError("Shouldn't receive WalletPayloadService errors here")
                        case .twoFactorOTPRequired:
                            fatalError("Shouldn't receive twoFactorOTPRequired error here")
                        }
                    }
                }
        )

    case .authenticateWithPassword:
        // clear error states
        return Effect(value: .showIncorrectPasswordError(false))

    case .alert(.show(let title, let message)):
        state.alert = AlertState(
            title: TextState(verbatim: title),
            message: TextState(verbatim: message),
            dismissButton: .default(TextState("OK"), send: .alert(.dismiss))
        )
        return .none

    case .alert(.dismiss):
        state.alert = nil
        return .none

    case .none:
        return .none
    }
}

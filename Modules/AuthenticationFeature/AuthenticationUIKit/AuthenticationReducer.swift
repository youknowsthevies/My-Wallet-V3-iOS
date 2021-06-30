// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public let authenticationReducer = Reducer<AuthenticationState, AuthenticationAction, AuthenticationEnvironment> { state, action, _ in
    switch action {
    case .start:
        return .none
    case .createAccount:
        state.isLoginVisible = false
        return .none
    case .login:
        return .none
    case .recoverFunds:
        return .none
    case .setLoginVisible(let isVisible):
        state.isLoginVisible = isVisible
        return .none
    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        return .none
    case .emailVerified(let isVerified):
        state.isEmailVerified = isVerified
        return .none
    case .verifyDevice(let url):
        // TODO: Extract the base64 from the url's fragment and process the data
        return .none
    case .didRetrievedWalletAddress(let walletAddress):
        state.walletAddress = walletAddress
        return .none
    case .setVerifyDeviceVisible(let isVisible):
        state.isVerifyDeviceVisible = isVisible
        return .none
    case .setPasswordLoginVisible(let isVisible):
        state.isPasswordLoginVisible = isVisible
        return .none
    case .didChangePassword(let password):
        state.password = password
        return .none
    case .didChangeTwoFactorAuthCode(let code):
        state.twoFactorAuthCode = code
        return .none
    case .didChangeHardwareKeyCode(let code):
        state.hardwareKeyCode = code
        return .none
    }
}

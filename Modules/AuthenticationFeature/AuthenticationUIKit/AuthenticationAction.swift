// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AuthenticationAction: Equatable {
    // MARK: - Start Action
    case start
    // MARK: - Welcome Screen
    case createAccount
    case login
    case recoverFunds

    // MARK: - Login Screen
    case setLoginVisible(Bool)
    case didChangeEmailAddress(String)
    case emailVerified(Bool)
    case didRetrievedWalletAddress(String)

    // MARK: - Verify Device Screen
    case setVerifyDeviceVisible(Bool)

    case verifyDevice(URL)

    // MARK: - Password Login Screen
    case setPasswordLoginVisible(Bool)
    case didChangePassword(String)
    case didChangeTwoFactorAuthCode(String)
    case didChangeHardwareKeyCode(String)
}

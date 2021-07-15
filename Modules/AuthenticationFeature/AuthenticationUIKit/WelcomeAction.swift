// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit

/*

 1. rename to welcome action
    - serves us navigating to welcome/login/verify/password screen
 2. make a Login Reducer for login screen actions (line 29 - 53)
 3. LoginState should be optional (depending on whether the login screen is triggered)
 4. wallet decrpyption stays in the main reducer (AuthenticationReducer)
 5. eventually: create wallet, recover wallet reducer

WelcomeAction
     case createAccount
     case login
     case recoverFunds

     // wallet decryption actions
     // MARK: - Wallet Decryption
     case pairWallet
     case authenticate
     case approveEmailAuthorization
     case pollWalletIdentifier
     case requestOTPMessage
     case authenticateWithTwoFA
     case authenticateWithPassword(String)

WelcomeReducer

WelcomeState


LoginReducer
     // MARK: - Login Screen
     case setLoginVisible(Bool)
     case didChangeEmailAddress(String)
     case verifyRecaptcha

     // MARK: - Verify Device Screen
     case setVerifyDeviceVisible(Bool)
     case verifyDevice(String)
     case didReceiveWalletInfoDeeplink(URL)
     case didExtractWalletInfo(WalletInfo)

     // MARK: - Password Login Screen
     case setPasswordLoginVisible(Bool)
     case setHardwareKeyCodeFieldVisible(Bool)
     case setTwoFACodeFieldVisible(Bool)
     case setResendSMSButtonVisible(Bool)
     case didChangePassword(String)
     case didChangeTwoFACode(String)
     case didChangeHardwareKeyCode(String)
     case showIncorrectPasswordError(Bool)
     case showIncorrectTwoFACodeError(Bool)
     case didChangeTwoFACodeAttemptsLeft(Int)
     case showIncorrectHardwareKeyCodeError(Bool)
     case showAccountLockedError(Bool)
     case setTwoFACodeVerified(Bool)
     case cancelPollingTimer

     // MARK: - Alerts
     case alert(AlertAction)

 */

public enum WelcomeAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }
    // MARK: - Start Action
    case start

    // MARK: - Welcome Screen
    case createWallet
    case login
    case recoverFunds

    // MARK: - Login Screen
    case onLoginDisappear
    case setLoginVisible(Bool)
    case didChangeEmailAddress(String)
    case verifyRecaptcha

    // MARK: - Verify Device Screen
    case setVerifyDeviceVisible(Bool)
    case verifyDevice(String)
    case didReceiveWalletInfoDeeplink(URL)
    case didExtractWalletInfo(WalletInfo)

    // MARK: - Password Login Screen
    case setPasswordLoginVisible(Bool)
    case setHardwareKeyCodeFieldVisible(Bool)
    case setTwoFACodeFieldVisible(Bool)
    case setResendSMSButtonVisible(Bool)
    case didChangePassword(String)
    case didChangeTwoFACode(String)
    case didChangeHardwareKeyCode(String)
    case showIncorrectPasswordError(Bool)
    case showIncorrectTwoFACodeError(Bool)
    case didChangeTwoFACodeAttemptsLeft(Int)
    case showIncorrectHardwareKeyCodeError(Bool)
    case showAccountLockedError(Bool)
    case setTwoFACodeVerified(Bool)
    case cancelPollingTimer

    // MARK: - Wallet Decryption
    case pairWallet
    case authenticate
    case approveEmailAuthorization
    case pollWalletIdentifier
    case requestOTPMessage
    case authenticateWithTwoFA
    case authenticateWithPassword(String)

    // MARK: - Alerts
    case alert(AlertAction)
    
    case none
}

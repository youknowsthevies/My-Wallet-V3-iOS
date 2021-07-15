// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture

public struct AuthenticationState: Equatable {

    // MARK: - Welcome Screen
    public var buildVersion: String = ""

    // MARK: - Login Screen
    public var isLoginVisible: Bool = false
    public var emailAddress: String = ""

    // MARK: - Verify Device Screen
    public var isVerifyDeviceVisible: Bool = false

    // MARK: - Password Login Screen
    public var isPasswordLoginVisible: Bool = false
    public var walletInfo: WalletInfo?

    public var password: String = ""
    public var isPasswordIncorrect: Bool = false

    public var twoFACode: String = ""
    public var isTwoFACodeFieldVisible = false
    public var isResendSMSButtonVisible = false
    public var isTwoFACodeIncorrect: Bool = false
    public var twoFACodeAttemptsLeft: Int = 5

    public var hardwareKeyCode: String = ""
    public var isHardwareKeyCodeFieldVisible = false
    public var isHardwareKeyCodeIncorrect: Bool = false

    public var isTwoFACodeVerified: Bool = false
    public var isAccountLocked: Bool = false

    // MARK: Alerts
    public var alert: AlertState<AuthenticationAction>?

    public init() {}
}

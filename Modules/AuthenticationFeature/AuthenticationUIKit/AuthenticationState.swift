// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct AuthenticationState: Equatable {

    // MARK: - Login Screen
    public var emailAddress: String = ""
    public var isLoginVisible: Bool = false
    public var isEmailVerified: Bool = false
    public var walletAddress: String = ""

    // MARK: - Verify Device Screen
    public var isVerifyDeviceVisible: Bool = false

    // MARK: - Password Login Screen
    public var password: String = ""
    public var twoFactorAuthCode: String = "" {
        didSet {
            if twoFactorAuthCode.count > 5 && oldValue.count <= 5 {
                twoFactorAuthCode = oldValue
            }
        }
    }
    public var hardwareKeyCode: String = ""

    public init() {}
}

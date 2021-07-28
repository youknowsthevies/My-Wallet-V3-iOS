// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class AccessibilityIdentifiers: NSObject {

    enum WelcomeScreen {
        static let prefix = "WelcomeScreen."

        static let blockchainImage = "\(prefix)blockchainImage"
        static let welcomeTitleText = "\(prefix)titleText"
        static let welcomeMessageText = "\(prefix)messageText"
        static let createWalletButton = "\(prefix)createWalletButton"
        static let emailLoginButton = "\(prefix)emailLoginButton"
        static let restoreWalletButton = "\(prefix)restoreWalletButton"
        static let manualPairingButton = "\(prefix)manualPairingButton"
        static let buildVersionText = "\(prefix)buildVersionText"
    }

    enum EmailLoginScreen {
        static let prefix = "EmailLoginScreen."

        static let emailGroup = "\(prefix)emailGroup"
        static let continueButton = "\(prefix)continueButton"
        static let loginTitleText = "\(prefix)loginTitleText"
    }

    enum ManualPairingScreen {
        static let prefix = "ManualPairingScreen."

        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let continueButton = "\(prefix)continueButton"
    }

    enum VerifyDeviceScreen {
        static let prefix = "VerifyDeviceScreen."

        static let verifyDeviceImage = "\(prefix)verifyDeviceImage"
        static let verifyDeviceTitleText = "\(prefix)verifyDeviceTitleText"
        static let verifyDeviceDescriptionText = "\(prefix)verifyDeviceDescriptionText"
        static let sendAgainButton = "\(prefix)sendAgainButton"
        static let openMailAppButton = "\(prefix)openMailAppButton"
    }

    enum CredentialsScreen {
        static let prefix = "CredentialsScreen."

        static let emailGuidGroup = "\(prefix)emailGuidGroup"
        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let troubleLoggingInButton = "\(prefix)troubleLoggingInButton"
        static let twoFAGroup = "\(prefix)twoFAGroup"
        static let resendSMSButton = "\(prefix)resendSMSButton"
        static let resetTwoFAButton = "\(prefix)resetTwoFAButton"
        static let hardwareKeyGroup = "\(prefix)hardwareKeyGroup"
    }
}

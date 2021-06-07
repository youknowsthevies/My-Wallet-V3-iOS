// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum AuthenticationKit { }
}

extension LocalizationConstants.AuthenticationKit {
    public enum Welcome {
        public enum Description {
            public static let prefix = NSLocalizedString(
                "The easy way to ",
                comment: "Welcome screen description: description prefix"
            )
            public static let comma = NSLocalizedString(
                ", ",
                comment: "Welcome screen description: comma separator"
            )
            public static let send = NSLocalizedString(
                "send",
                comment: "Welcome screen description: send word"
            )
            public static let receive = NSLocalizedString(
                "receive",
                comment: "Welcome screen description: receive word"
            )
            public static let store = NSLocalizedString(
                "store",
                comment: "Welcome screen description: store word"
            )
            public static let and = NSLocalizedString(
                " and ",
                comment: "Welcome screen description: store word"
            )
            public static let trade = NSLocalizedString(
                "trade",
                comment: "Welcome screen description: trade word"
            )
            public static let suffix = NSLocalizedString(
                " digital currencies.",
                comment: "Welcome screen description: suffix"
            )
        }
        public enum Button {
            public static let createAccount = NSLocalizedString(
                "Create an Account",
                comment: "Welcome screen: create account CTA button"
            )
            public static let login = NSLocalizedString(
                "Log In",
                comment: "Welcome screen: login CTA button"
            )
            public static let recoverFunds = NSLocalizedString(
                "Recover Funds",
                comment: "Welcome screen: recover funds CTA button"
            )
        }
        public static let title = NSLocalizedString(
            "Welcome to Blockchain",
            comment: "Welcome screen: title"
        )
    }

    public enum Login {
        public static let navigationTitle = NSLocalizedString(
            "Login",
            comment: "Login screen: login form title"
        )
        public enum TextFieldTitle {
            public static let email = NSLocalizedString(
                "Email",
                comment: "Login screen: email text field title"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Login screen: password field title"
            )
            public static let twoFactorAuthCode = NSLocalizedString(
                "2FA Code",
                comment: "Login screen: two factor authentication text field title"
            )
            public static let hardwareKeyVerify = NSLocalizedString(
                "Verify with your |HARDWARE KEY|",
                comment: "Login screen: verify with hardware key title prefix"
            )
        }
        public enum TextFieldPlaceholder {
            public static let email = NSLocalizedString(
                "your@email.com",
                comment: "Login screen: placeholder for email text field"
            )
        }
        public enum TextFieldFootnote {
            public static let wallet = NSLocalizedString(
                "Wallet: ",
                comment: "Login screen: prefix for wallet identifier footnote"
            )
            public static let incorrectPassword = NSLocalizedString(
                "Incorrect Password",
                comment: "Login screen: wrong password footnote"
            )
            public static let troubleLogInPrompt = NSLocalizedString(
                "Trouble logging in?",
                comment: "Login screen: prompt for forgot password"
            )
            public static let incorrectTwoFactorAuthCode = NSLocalizedString(
                "Incorrect 2FA Code",
                comment: "Login screen: wrong 2FA code footnote"
            )
            public static let hardwareKeyInstruction = NSLocalizedString(
                "Tap |HARDWARE KEY| to verify",
                comment: "Login screen: hardware key usage instruction"
            )
            public static let incorrectHardwareKey = NSLocalizedString(
                "Incorrect |HARDWARE KEY| code",
                comment: "Login screen: wrong hardware key"
            )
        }
        public enum Divider {
            public static let or = NSLocalizedString(
                "or",
                comment: "Login screen: Divider OR label")
        }
        public enum Button {
            public static let scanPairingCode = NSLocalizedString(
                "Scan Pairing Code",
                comment: "Login screen: scan pairing code CTA button"
            )
            public static let apple = NSLocalizedString(
                "Continue with Apple",
                comment: "Login screen: sign in with Apple CTA button"
            )
            public static let google = NSLocalizedString(
                "Continue with Google",
                comment: "Login screen: sign in with Google CTA button"
            )
            public static let _continue = NSLocalizedString(
                "Continue",
                comment: "Login screen: continue CTA button")
        }
    }

    public enum VerifyDevice {
        public static let title = NSLocalizedString(
            "Verify Device",
            comment: "Verify device screen: Verify device screen title"
        )
        public static let description = NSLocalizedString(
            "If you have an account registered with this email address, you will receive an email with a link to verify your device.",
            comment: "Verify device screen: Verify device screen description")
        public enum Button {
            public static let openEmail = NSLocalizedString(
                "Open Email App",
                comment: "Verify device screen: Open email app CTA button"
            )
            public static let sendAgain = NSLocalizedString(
                "Send Again",
                comment: "Verify device screen: Send email again CTA button"
            )
        }
    }
}

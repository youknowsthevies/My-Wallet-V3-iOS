// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum AuthenticationKit {}
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
            public static let createWallet = NSLocalizedString(
                "Create a Wallet",
                comment: "Welcome screen: create wallet CTA button"
            )
            public static let login = NSLocalizedString(
                "Log In",
                comment: "Welcome screen: login CTA button"
            )
            public static let restoreWallet = NSLocalizedString(
                "Restore Wallet",
                comment: "Welcome screen: restore wallet CTA button"
            )
        }

        public static let title = NSLocalizedString(
            "Welcome to Blockchain",
            comment: "Welcome screen: title"
        )
    }

    public enum EmailLogin {
        public static let navigationTitle = NSLocalizedString(
            "Login",
            comment: "Login screen: login form title"
        )
        public enum VerifyDevice {
            public static let title = NSLocalizedString(
                "Verify Device",
                comment: "Verify device screen: Verify device screen title"
            )
            public static let description = NSLocalizedString(
                "If you have an account registered with this email address, you will receive an email with a link to verify your device.",
                comment: "Verify device screen: Verify device screen description"
            )
            public enum Button {}
        }

        public enum TextFieldTitle {
            public static let email = NSLocalizedString(
                "Email",
                comment: "Login screen: email text field title"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Login screen: password field title"
            )
            public static let twoFACode = NSLocalizedString(
                "2FA Code",
                comment: "Login screen: two factor authentication text field title"
            )
            public static let hardwareKeyCode = NSLocalizedString(
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
            public static let hardwareKeyInstruction = NSLocalizedString(
                "Tap |HARDWARE KEY| to verify",
                comment: "Login screen: hardware key usage instruction"
            )
            public static let lostTwoFACodePrompt = NSLocalizedString(
                "Lost access to your 2FA device?",
                comment: "Login screen: a prompt for user to reset their 2FA if they lost their 2FA device"
            )
        }

        public enum TextFieldError {
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email",
                comment: "Login screen: invalid email error"
            )
            public static let incorrectPassword = NSLocalizedString(
                "Incorrect Password",
                comment: "Login screen: wrong password error"
            )
            public static let missingTwoFACode = NSLocalizedString(
                "Missing 2FA code",
                comment: "Login screen: missing 2FA code error"
            )
            public static let incorrectTwoFACode = NSLocalizedString(
                "Incorrect 2FA code. %d attempts left",
                comment: "Login screen: wrong 2FA code error"
            )
            public static let incorrectHardwareKeyCode = NSLocalizedString(
                "Incorrect |HARDWARE KEY| code",
                comment: "Login screen: wrong hardware key error"
            )
            public static let accountLocked = NSLocalizedString(
                "This account has been locked due to too many failed authentications",
                comment: "Login screen: a message saying that the account is locked"
            )
        }

        public enum Link {
            public static let troubleLogInLink = NSLocalizedString(
                "Trouble logging in?",
                comment: "Login screen: link for forgot password"
            )
            public static let resetTwoFALink = NSLocalizedString(
                "Reset your 2FA",
                comment: "Login screen: link for resetting 2FA"
            )
        }

        public enum Divider {
            public static let or = NSLocalizedString(
                "or",
                comment: "Login screen: Divider OR label"
            )
        }

        public enum Button {
            public static let scanPairingCode = NSLocalizedString(
                "Scan Pairing Code",
                comment: "Login screen: scan pairing code CTA button"
            )
            public static let openEmail = NSLocalizedString(
                "Open Email App",
                comment: "Verify device screen: Open email app CTA button"
            )
            public static let sendAgain = NSLocalizedString(
                "Send Again",
                comment: "Verify device screen: Send email again CTA button"
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
                comment: "Login screen: continue CTA button"
            )
            public static let resendSMS = NSLocalizedString(
                "Resend SMS",
                comment: "Login screen: resend SMS for 2FA CTA button"
            )
        }
    }
}

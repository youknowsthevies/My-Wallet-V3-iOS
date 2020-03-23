//
//  LocalizationConstants+TextField.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public extension LocalizationConstants {
    struct TextField {
        public struct Placeholder {
            public static let email = NSLocalizedString(
                "Your Email",
                comment: "Placeholder for email text field"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Placeholder for password text field"
            )
            public static let confirmPassword = NSLocalizedString(
                "Confirm Password",
                comment: "Placeholder for confirm password text field"
            )
            public static let recoveryPhrase = NSLocalizedString(
                "Recovery passphrase",
                comment: "Placeholder for recovery passphrase text field"
            )
            public static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Placeholder for wallet identifier text field"
            )
            public static let mobile = NSLocalizedString("Mobile Number", comment: "Placeholder for mobile number entry")
            public static let word = NSLocalizedString("word", comment: "Partial placeholder for mnemonic word entry. e.g. \"1st word\" ")
            public static let oneTimeCode = NSLocalizedString("XXXX", comment: "Placeholder for a one time code.")
        }
        
        public struct PasswordScore {
            public static let weak = NSLocalizedString(
                "Weak",
                comment: "Label for a Weak password score in password text field"
            )
            public static let normal = NSLocalizedString(
                "Regular",
                comment: "Label for a Normal password score in password text field"
            )
            public static let strong = NSLocalizedString(
                "Strong",
                comment: "Label for a Strong password score in password text field"
            )
        }
        
        public struct Gesture {
            public static let passwordMismatch = NSLocalizedString(
                "Password do not match",
                comment: "Error label when two passwords do not match"
            )
            public static let invalidEmail = NSLocalizedString(
                "Email address is not valid",
                comment: "Error label when email address is not valid"
            )
            public static let invalidMobile = NSLocalizedString("Invalid mobile number", comment: "Error label when the mobile number is incorrect")
            public static let invalidRecoveryPhrase = NSLocalizedString(
                "Invalid recovery phrase. Please try again,",
                comment: "Error label when the recovery phrase is incorrect"
            )
            public static let walletId = NSLocalizedString(
                "Wallet id is not valid",
                comment: "Error label when wallet id is not valid"
            )
            public static let invalidCode = NSLocalizedString("Invalid Code", comment: "The four digit code is invalid")
            public static let recoveryMismatch = NSLocalizedString(
                "The word does not match your Recovery Phrase",
                comment: "Error label when the word does not match the word in the mnemonic."
            )
        }
    }
}

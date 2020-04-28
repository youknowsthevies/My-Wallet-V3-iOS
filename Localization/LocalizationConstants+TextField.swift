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
        public struct CardType {
            public static let visa = NSLocalizedString(
                "Visa",
                comment: "Card type: VISA"
            )
            public static let mastercard = NSLocalizedString(
                "Mastercard",
                comment: "Card type: Mastercard"
            )
            public static let amex = NSLocalizedString(
                "American Express",
                comment: "Card type: American Express"
            )
            public static let diners = NSLocalizedString(
                "Diners Club",
                comment: "Card type: Diners"
            )
            public static let discover = NSLocalizedString(
                "Discover",
                comment: "Card type: Discover"
            )
            public static let jcb = NSLocalizedString(
                "JCB",
                comment: "Card type: JCB"
            )
            public static let unknown = NSLocalizedString(
                "Unknown Card Type",
                comment: "Card type: Unknown"
            )
        }
        public struct Placeholder {
            public struct Card {
                public static let name = NSLocalizedString(
                    "Name on Card",
                    comment: "Placeholder for card owner name text field"
                )
                public static let number = NSLocalizedString(
                    "Card Number",
                    comment: "Placeholder for card number text field"
                )
                public static let expirationDate = NSLocalizedString(
                    "Expiry Date",
                    comment: "Placeholder for card expiry date text field"
                )
                public static let cvv = NSLocalizedString(
                    "CVV",
                    comment: "Placeholder for card cvv text field"
                )
            }
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
            public static let mobile = NSLocalizedString(
                "Mobile Number",
                comment: "Placeholder for mobile number entry"
            )
            public static let word = NSLocalizedString(
                "word",
                comment: "Partial placeholder for mnemonic word entry. e.g. \"1st word\" "
            )
            public static let oneTimeCode = NSLocalizedString(
                "XXXX",
                comment: "Placeholder for a one time code."
            )
            public static let addressLine = NSLocalizedString(
                "Address Line",
                comment: "Placeholder for address line # text field"
            )
            public static let fullName = NSLocalizedString(
                "Full Name",
                comment: "Placeholder for person's full name text field"
            )
            public static let city = NSLocalizedString(
                "City",
                comment: "Placeholder for city text field"
            )
            public static let state = NSLocalizedString(
                "State",
                comment: "Placeholder for state text field"
            )
            public static let postCode = NSLocalizedString(
                "Post Code",
                comment: "Placeholder for post code text field"
            )
            public static let zip = NSLocalizedString(
                "Zip",
                comment: "Placeholder for zip text field"
            )
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
            public static let invalidCardNumber = NSLocalizedString(
                "Invalid card number",
                comment: "Error label when the card number is invalid"
            )
            public static let unsupportedCardType = NSLocalizedString(
                "Card not supported",
                comment: "Error label when the card type is not supported"
            )
            public static let invalidExpirationDate = NSLocalizedString(
                "Invalid expiry date",
                comment: "Error label when the expiry date is invalid"
            )
            public static let invalidCVV = NSLocalizedString(
                "Invalid CVV",
                comment: "Error label when the CVV is invalid"
            )
            public static let invalidCardholderName = NSLocalizedString(
                "Invalid cardholder name",
                comment: "Error label when the name is invalid"
            )
            public static let walletId = NSLocalizedString(
                "Wallet id is not valid",
                comment: "Error label when wallet id is not valid"
            )
            public static let invalidCode = NSLocalizedString(
                "Invalid Code",
                comment: "The four digit code is invalid"
            )
            public static let recoveryMismatch = NSLocalizedString(
                "The word does not match your Recovery Phrase",
                comment: "Error label when the word does not match the word in the mnemonic."
            )
        }
    }
}

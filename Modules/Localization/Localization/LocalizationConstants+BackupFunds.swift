// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum BackupFundsScreen { }
    public enum RecoveryPhraseScreen { }
    public enum VerifyBackupScreen { }
}

// MARK: BackupFundsScreen

public extension LocalizationConstants.BackupFundsScreen {

    static let title = NSLocalizedString("Secret Private Key Recovery", comment: "Screen title.")
    static let action = NSLocalizedString("View Recovery Phrase", comment: "Button titleView Recovery Phrase.")

    enum Body {
        public static let partA = NSLocalizedString(
            "In crypto, when you hold the private keys, you're in control of the funds in your Private Key Wallet. The downside is that WHOEVER holds your private keys can control your Private Key Wallet.",
            comment: ""
        )
        public static let partB = NSLocalizedString(
            "Warning: If someone has your backup phrase they will have access to your Private Key Wallet and can withdraw funds.",
            comment: ""
        )
        public static let notice = NSLocalizedString(
            "Blockchain.com will never ask to view or receive your recovery phrase.",
            comment: ""
        )
        public enum List {
            public static let title = NSLocalizedString(
                "So you must:",
                comment: ""
            )
            public static let item1 = NSLocalizedString(
                "1. Write down the 12 word phrase on the next screen in the exact order it appears.",
                comment: ""
            )
            public static let item2 = NSLocalizedString(
                "2. Keep it safe, ideally on a securely stored piece of paper (in other words, not a digital copy).",
                comment: ""
            )
            public static let item3 = NSLocalizedString(
                "3. NEVER share your backup phrase with anyone.",
                comment: ""
            )
        }
    }
}


// MARK: RecoveryPhraseScreen

public extension LocalizationConstants.RecoveryPhraseScreen {
    static let title = NSLocalizedString("Recovery Phrase", comment: "Recovery Phrase")
    static let subtitle = NSLocalizedString("Write Down Recovery Phrase", comment: "Write Down Recovery Phrase")
    static let description = NSLocalizedString(
        "For your security, Blockchain does not keep any passwords on file. The following 12 word Backup Phrase will give you access to your funds in case you lose your password. Be sure to write it on a piece of paper and to keep it somewhere safe and secure.",
        comment: "For your security, Blockchain does not keep any passwords on file. The following 12 word Backup Phrase will give you access to your funds in case you lose your password. Be sure to write it on a piece of paper and to keep it somewhere safe and secure."
    )
    static let copyToClipboard = NSLocalizedString("Copy to Clipboard", comment: "Copy to Clipboard")
    static let next = NSLocalizedString("Next", comment: "Next")
}

// MARK: VerifyBackupScreen

public extension LocalizationConstants.VerifyBackupScreen {
    static let title = NSLocalizedString(
        "Verify Your Backup",
        comment: "Verify Your Backup"
    )
    static let description = NSLocalizedString(
        "Enter the following words from your Backup Phrase to complete the backup process.",
        comment: "Enter the following words from your Backup Phrase to complete the backup process."
    )
    static let action = NSLocalizedString(
        "Verify",
        comment: "Verify"
    )
    static let errorDescription = NSLocalizedString(
        "The words in your Recovery Phrase didn’t match. You can go back to the previous step and double check you wrote it down correctly",
        comment: "The words in your Recovery Phrase didn’t match. You can go back to the previous step and double check you wrote it down correctly"
    )

    enum Index {
        public static let first = NSLocalizedString("first word", comment: "first word")
        public static let second = NSLocalizedString("second word", comment: "second word")
        public static let third = NSLocalizedString("third word", comment: "third word")
        public static let fourth = NSLocalizedString("fourth word", comment: "fourth word")
        public static let fifth = NSLocalizedString("fifth word", comment: "fifth word")
        public static let sixth = NSLocalizedString("sixth word", comment: "sixth word")
        public static let seventh = NSLocalizedString("seventh word", comment: "seventh word")
        public static let eighth = NSLocalizedString("eighth word", comment: "eighth word")
        public static let ninth = NSLocalizedString("ninth word", comment: "ninth word")
        public static let tenth = NSLocalizedString("tenth word", comment: "tenth word")
        public static let eleventh = NSLocalizedString("eleventh", comment: "eleventh word")
        public static let twelfth = NSLocalizedString("twelfth word", comment: "twelfth word")
    }
}

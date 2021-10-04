// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

extension LocalizationConstants {
    public enum CustomerSupport {
        public static let name = NSLocalizedString(
            "Blockchain.com Live Support",
            comment: "Blockchain.com Live Support"
        )
        public static let title = NSLocalizedString(
            "Customer Support",
            comment: "Customer Support"
        )
        public enum Heading {
            public static let title = NSLocalizedString(
                "What topic do you need help with?",
                comment: "What topic do you need help with?"
            )
        }

        public enum Item {
            public static let idVerification = NSLocalizedString(
                "Identity Verification",
                comment: "Identity Verification"
            )
            public static let wallet = NSLocalizedString(
                "Wallet",
                comment: "Wallet"
            )
            public static let securityConcern = NSLocalizedString(
                "Security Concern",
                comment: "Security Concern"
            )
        }
    }
}

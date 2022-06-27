import Foundation

// swiftlint:disable type_name
// swiftlint:disable line_length

extension LocalizationConstants {
    public enum UserDeletion {
        public enum MainScreen {
            public static let navBarTitle = NSLocalizedString(
                "Delete Account",
                comment: "UserDeletion main screen navBar title"
            )

            public static let header = (
                title: NSLocalizedString(
                    "Are you sure?",
                    comment: "UserDeletion main screen header title"
                ),
                subtitle: NSLocalizedString(
                    "Deleting your account means:",
                    comment: "UserDeletion main screen header subtitle"
                )
            )

            public static let bulletPoints = (
                first: NSLocalizedString(
                    "Your Trading and Rewards Accounts will be deleted",
                    comment: "UserDeletion main screen, first bullet point"
                ),
                second: NSLocalizedString(
                    "You will be logged out on all devices",
                    comment: "UserDeletion main screen, second bullet point"
                )
            )

            public static let withdrawBanner = (
                title: NSLocalizedString(
                    "Withdraw Funds",
                    comment: "UserDeletion main screen withdraw banner title"
                ),
                subtitle: NSLocalizedString(
                    "Please withdraw all funds from your accounts and wallets. Deleting your account is permanent.",
                    comment: "UserDeletion main screen withdraw banner subtitle"
                )
            )

            public static let externalLinks = (
                dataRetention: NSLocalizedString(
                    "Data Retention Policy",
                    comment: "UserDeletion main screen, external link for data retention policy"
                ),
                needHelp: NSLocalizedString(
                    "Need Help?",
                    comment: "UserDeletion main screen, external link for help"
                )
            )

            public static let mainCTA = NSLocalizedString(
                "Delete Account",
                comment: "UserDeletion main screen, main CTA"
            )
        }
    }
}

extension LocalizationConstants.UserDeletion {
    public enum ConfirmationScreen {
        public static let navBarTitle = NSLocalizedString(
            "Confirmation",
            comment: "UserDeletion Confirmation screen navBar title"
        )

        public static let explanaition = NSLocalizedString(
            "By confirming below, you acknowledge that any funds left in your account cannot be recovered",
            comment: "UserDeletion Confirmation screen explanation"
        )

        public static let textField = (
            label: NSLocalizedString(
                "Type ‘DELETE MY ACCOUNT’ to confirm",
                comment: "UserDeletion Confirmation screen textfield label"
            ),
            placeholder: NSLocalizedString(
                "DELETE MY ACCOUNT",
                comment: "UserDeletion Confirmation screen textfield placeholder"
            ),
            errorSubText: NSLocalizedString(
                "Please enter the phrase exactly as shown to confirm",
                comment: "UserDeletion Confirmation screen textfield error message"
            )
        )

        public static let mainCTA = NSLocalizedString(
            "Delete Account",
            comment: "UserDeletion Confirmation screen, main CTA"
        )

        public static let processing = NSLocalizedString(
            "Processing...",
            comment: "UserDeletion Confirmation screen, text for waiting for the BE response"
        )
    }
}

extension LocalizationConstants.UserDeletion {
    public enum ResultScreen {
        public static let success = (
            message: NSLocalizedString(
                "We have successfully deleted your account",
                comment: "UserDeletion Result screen, deletion success message"
            ),
            reason: String() // Just to keep the tuple pattern
        )

        public static let failure = (
            message: NSLocalizedString(
                "Failed to delete your account due to the following reason",
                comment: "UserDeletion Result screen, deletion failure message"
            ),
            reason: NSLocalizedString(
                "You have a remaining balance",
                comment: "UserDeletion Result screen, deletion failure reason"
            )
        )

        public static let mainCTA = NSLocalizedString(
            "OK",
            comment: "UserDeletion Result screen, main CTA"
        )
    }
}

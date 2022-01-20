// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Onboarding {}
}

extension LocalizationConstants.Onboarding {

    public enum ChecklistOverview {

        public static let title = NSLocalizedString(
            "Complete Your Profile",
            comment: "Onboarding checklist overview title"
        )

        public static let subtitle = NSLocalizedString(
            "Buy Crypto Today",
            comment: "Onboarding checklist overview subtitle"
        )
    }

    public enum Checklist {

        public static let screenTitle = NSLocalizedString(
            "Complete Your Profile.\nBuy Crypto Today.",
            comment: "Onboarding checklist view title"
        )

        public static let screenSubtitle = NSLocalizedString(
            "Finish setting up your Blockchain.com account and start buying crypto today.",
            comment: "Onboarding checklist view subtitle"
        )

        public static let listTitle = NSLocalizedString(
            "Your steps towards owning the future.",
            comment: "Onboarding checklist title"
        )

        public static let pendingPlaceholder = NSLocalizedString(
            "Processing...",
            comment: "Onboarding checklist item subtitle displaying that the item's status is being actioned upon"
        )

        public static let verifyIdentityTitle = NSLocalizedString(
            "Verify Your ID",
            comment: "Onboarding checklist item title - verify identity"
        )

        public static let verifyIdentitySubtitle = NSLocalizedString(
            "3 Minutes",
            comment: "Onboarding checklist item subtitle - verify identity"
        )

        public static let linkPaymentMethodsTitle = NSLocalizedString(
            "Link a Payment Method",
            comment: "Onboarding checklist item title - link payment methods"
        )

        public static let linkPaymentMethodsSubtitle = NSLocalizedString(
            "2 Minutes",
            comment: "Onboarding checklist item subtitle - link payment methods"
        )

        public static let buyCryptoTitle = NSLocalizedString(
            "Buy Crypto",
            comment: "Onboarding checklist item title - buy crypto"
        )

        public static let buyCryptoSubtitle = NSLocalizedString(
            "10 Seconds",
            comment: "Onboarding checklist item subtitle - buy crypto"
        )

        public static let requestCryptoTitle = NSLocalizedString(
            "Receive Crypto",
            comment: ""
        )

        public static let requestCryptoSubtitle: String? = nil
    }

    public enum CryptoBalanceRequired {

        public static let title = NSLocalizedString(
            "You’ll need some crypto first!",
            comment: ""
        )

        public static let subtitle = NSLocalizedString(
            "Link a bank or card and buy now or receive from a friend. Once you hold a balance, you can swap crypto at anytime.",
            comment: ""
        )
    }
}

extension LocalizationConstants.Onboarding {
    public static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
    public static let termsOfServiceAndPrivacyPolicyNoticePrefix = NSLocalizedString("By creating a wallet you agree to Blockchain’s", comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they create a wallet")
    public static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
    public static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
    public static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
    public static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
    public static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
    public static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")

    public enum IntroductionSheet {
        public static let next = NSLocalizedString("Next", comment: "Next")
        public enum Home {
            public static let title = NSLocalizedString("View Your Portfolio", comment: "View Your Portfolio")
            public static let description = NSLocalizedString(
                "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and PAX.",
                comment: "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and PAX."
            )
        }

        public enum Send {
            public static let title = NSLocalizedString("Send", comment: "Send")
            public static let description = NSLocalizedString(
                "Send crypto anywhere, anytime. All you need is the recipient’s crypto address.",
                comment: "Send crypto anywhere, anytime. All you need is the recipient’s crypto address."
            )
        }

        public enum Request {
            public static let title = NSLocalizedString("Request", comment: "Request")
            public static let description = NSLocalizedString(
                "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here.",
                comment: "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here."
            )
        }

        public enum Swap {
            public static let title = NSLocalizedString("Swap", comment: "Swap")
            public static let description = NSLocalizedString(
                "Trade crypto with low fees without leaving your wallet.",
                comment: "Trade crypto with low fees without leaving your wallet."
            )
        }

        public enum BuySell {
            public static let title = NSLocalizedString("Buy & Sell", comment: "Buy & Sell")
            public static let description = NSLocalizedString(
                "Jumpstart your crypto portfolio by easily buying and selling Bitcoin.",
                comment: "Jumpstart your crypto portfolio by easily buying and selling Bitcoin."
            )
        }
    }
}

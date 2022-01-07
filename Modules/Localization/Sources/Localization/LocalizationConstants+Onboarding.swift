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

        public static let verifyIdentityTitle = NSLocalizedString(
            "Verify Your ID",
            comment: "Onboarding checklist item title - verify identity"
        )

        public static let verifyIdentitySubtitle = NSLocalizedString(
            "3 Minutes",
            comment: "Onboarding checklist item subtitle - verify identity"
        )

        public static let linkPaymentMethodsTitle = NSLocalizedString(
            "Link a Bank or Card",
            comment: "Onboarding checklist item title - link payment methods"
        )

        public static let linkPaymentMethodsSubtitle = NSLocalizedString(
            "2 Minutes",
            comment: "Onboarding checklist item subtitle - link payment methods"
        )

        public static let butCryptoTitle = NSLocalizedString(
            "Buy Crypto",
            comment: "Onboarding checklist item title - buy crypto"
        )

        public static let butCryptoSubtitle = NSLocalizedString(
            "10 Seconds",
            comment: "Onboarding checklist item subtitle - buy crypto"
        )
    }
}

extension LocalizationConstants.Onboarding {
    public enum CreateWalletScreen {
        public static let title = NSLocalizedString(
            "Buy Crypto Now",
            comment: "Create new wallet screen title"
        )
        public static let button = NSLocalizedString(
            "Buy Crypto Now",
            comment: "Create new wallet screen CTA button"
        )
        public enum TermsOfUse {
            public static let prefix = NSLocalizedString(
                "By creating a wallet you agree to Blockchain’s ",
                comment: "Create new wallet screen TOS prefix"
            )
            public static let termsOfServiceLink = NSLocalizedString(
                "Terms of Service",
                comment: "Create new wallet screen TOS terms part"
            )
            public static let linkDelimiter = NSLocalizedString(
                " & ",
                comment: "Create new wallet screen TOS terms part"
            )
            public static let privacyPolicyLink = NSLocalizedString(
                "Privacy Policy",
                comment: "Create new wallet screen TOS privacy policy part"
            )
        }

        // TODO: Format it properly
        public static let termsOfUseFormat = NSLocalizedString(
            "By creating a wallet you agree to Blockchain’s Terms of Services & Privacy Policy",
            comment: "Create new wallet screen terms of use text label"
        )
    }

    public enum PasswordRequiredScreen {
        public static let title = NSLocalizedString(
            "Password Required",
            comment: "Password required screen title"
        )
        public static let continueButton = NSLocalizedString(
            "Continue",
            comment: "Password required CTA"
        )
        public static let forgotButton = NSLocalizedString(
            "Forgot Password?",
            comment: "Forgot password CTA"
        )
        public static let forgetWalletButton = NSLocalizedString(
            "Forget Wallet",
            comment: "Forget wallet CTA"
        )
        public static let loadingLabel = NSLocalizedString(
            "Loading Your Wallet",
            comment: "Password required: Loading label after the user inserts password"
        )
        public static let description = NSLocalizedString(
            "You have logged out or there was an error decrypting your wallet file. Enter your password below to login.",
            comment: "Description of Password Required form"
        )
        public static let forgetWalletDescription = NSLocalizedString(
            "If you would like to forget this wallet and start over, press 'Forget Wallet'.",
            comment: "Description of forget wallet functionality."
        )
        public enum ForgotPasswordAlert {
            public static let title = NSLocalizedString(
                "Open Support",
                comment: "forgot password alert title"
            )
            public static let message = NSLocalizedString(
                "You will be redirected to\n%@.",
                comment: "forgot password alert body"
            )
        }

        public enum ForgetWalletAlert {
            public static let title = NSLocalizedString(
                "Warning",
                comment: "forget wallet alert title"
            )
            public static let message = NSLocalizedString(
                "This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere, otherwise any bitcoin in this wallet will be inaccessible!",
                comment: "forget wallet alert body"
            )
            public static let forgetButton = NSLocalizedString(
                "Forget wallet",
                comment: "forget wallet alert button"
            )
        }
    }

    public enum RecoverFunds {
        public static let title = NSLocalizedString(
            "Recover Funds",
            comment: "Title of the recover funds screen"
        )
        public static let description = NSLocalizedString(
            "Enter your 12 recovery words with spaces to recover your funds & transactions",
            comment: "Description of what to type into the recover funds screen"
        )
        public static let placeholder = NSLocalizedString(
            "Recovery phrase",
            comment: "Placeholder for the text field on the Recover Funds screen."
        )
        public static let button = NSLocalizedString(
            "Continue",
            comment: "CTA on the recover funds screen"
        )
    }

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

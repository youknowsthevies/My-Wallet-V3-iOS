//
//  LocalizationConstants+SimpleBuy.swift
//  Localization
//
//  Created by Paulo on 11/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum SimpleBuy { }
}

extension LocalizationConstants.SimpleBuy {
    public enum Withdrawal {
        public static let title = NSLocalizedString(
            "Send to",
            comment: "Send to"
        )
        public enum Description {
            public static let prefix = NSLocalizedString(
                "At this time, Blockchain.com only allows sending your total amount from your",
                comment: "At this time, Blockchain.com only allows sending your total amount from your"
            )
            public static let suffix = NSLocalizedString(
                "trading wallet",
                comment: "trading wallet"
            )
        }

        public static let action = NSLocalizedString("Send", comment: "Send")

        public enum SummarySuccess {
            public static let title = NSLocalizedString("Success!", comment: "Success!")
            public static let sent = NSLocalizedString("Sent", comment: "Sent")
            public static let description = NSLocalizedString(
                "It may take up to 1 hour for your transaction to be processed.",
                comment: "It may take up to 1 hour for your transaction to be processed."
            )
            public static let action = NSLocalizedString("Done", comment: "Done")
        }

        public enum SummaryFailure {
            public enum Unknown {
                public static let title = NSLocalizedString("Oops!", comment: "Oops!")
                public static let description = NSLocalizedString(
                    "Something went wrong. Please go back and try again.",
                    comment: "Something went wrong. Please go back and try again."
                )
            }
            public enum WithdrawLocked {
                public static let title = NSLocalizedString("Funds Locked", comment: "Funds Locked")
                public static let description = NSLocalizedString(
                    "Your crypto will be available to be withdrawn within 7 days.",
                    comment: "Your crypto will be available to be withdrawn within 7 days."
                )
            }
            public static let action = NSLocalizedString("OK", comment: "OK")
        }
    }
    public enum Ineligible {
        public static let title = NSLocalizedString("is Not Supported",
                                                    comment: "is Not Supported")
        public static let description = NSLocalizedString("Currently we don’t support buying crypto with",
                                                          comment: "Currently we don’t support buying crypto with")
        public static let changeCurrency = NSLocalizedString("Change Currency",
                                                             comment: "Change Currency")
        public static let viewHome = NSLocalizedString("View Home",
                                                       comment: "View Home")
    }
    public enum PaymentMethodSelectionScreen {
        public static let title = NSLocalizedString(
            "Payment Methods",
            comment: "Simple Buy: Payment method selection screen title"
        )
        public struct Card {
            public static let title = NSLocalizedString(
                "Add Credit or Debit Card",
                comment: "Simple Buy: Payment method selection screen: card title"
            )
            public static let descriptionLimit = NSLocalizedString(
                "Limit",
                comment: "Simple Buy: Payment method selection screen: description of card payment max limit"
            )
            public static let descriptionInfo = NSLocalizedString(
                "Instantly buy crypto with any Visa or Mastercard.",
                comment: "Simple Buy: Payment method selection screen: description of card"
            )
            public static let badgeTitle = NSLocalizedString(
                "Most Popular",
                comment: "Simple Buy: Payment method selection screen: promotional text for card payment"
            )
        }
        public struct DepositCash {
            public static let title = NSLocalizedString(
                "Deposit Cash",
                comment: "Simple Buy: Payment method selection screen: deposit funds title"
            )
            public static let description = NSLocalizedString(
                "Send funds directly from your bank to your Blockchain.com Wallet. Once we receive the manual transfer, use that cash to buy crypto.",
                comment: "Simple Buy: Payment method selection screen: description of Deposit Funds"
            )
        }
        public enum Types {
            public static let bankWireTitle = NSLocalizedString(
                "Bank Wire Transfer",
                comment: "Simple Buy: Payment method selection screen: bank wire transfer"
            )
            public static let cardTitle = NSLocalizedString(
                "Credit or Debit Card",
                comment: "Simple Buy: Payment method selection screen: card"
            )
            public static let limitSubtitle = NSLocalizedString(
                "Limit",
                comment: "Simple Buy: Payment method selection screen: type subtitle (max amount limit)"
            )
            public static let available = NSLocalizedString(
                "Available",
                comment: "Simple Buy: Payment method selection screen: funds type subtitle (max amount limit)"
            )
            public static let selectCashOrCard = NSLocalizedString(
                "Select Cash or Card",
                comment: "Simple Buy: Payment method selection screen: select cash or card"
            )
        }
    }
    public enum CryptoSelectionScreen {
        public static let title = NSLocalizedString(
            "Select Currency",
            comment: "Simple Buy: Crypto selection screen title"
        )
        public static let searchBarPlaceholder = NSLocalizedString(
            "Search Currency",
            comment: "Simple Buy: Crypto selection screen search bar placeholder"
        )
    }
    public enum CountrySelectionScreen {
        public static let title = NSLocalizedString(
            "Select Country",
            comment: "Simple Buy: Country selection screen title"
        )
    }
    public enum BuyCryptoScreen {
        public static let title = NSLocalizedString(
            "Buy Crypto",
            comment: "Simple Buy: Buy Crypto screen title"
        )
        public static let ctaButton = NSLocalizedString(
            "Continue",
            comment: "Simple Buy: Buy Crypto Screen - CTA button"
        )
        public static let paymentMethodTitle = NSLocalizedString(
            "Payment Method",
            comment: "Simple Buy: Buy Crypto Screen - payment method title label"
        )
        public enum LimitView {
            public static let upperLimit = NSLocalizedString(
                "Up to %@",
                comment: "Simple Buy: Buy Crypto Screen - Amount upper limit"
            )
            public enum Min {
                public static let useMin = NSLocalizedString(
                    "Min",
                    comment: "Simple Buy: Buy Crypto Screen - Amount too low suffix"
                )
            }

            public enum Max {
                public static let useMax = NSLocalizedString(
                    "Max",
                    comment: "Simple Buy: Buy Crypto Screen - Amount too high suffix"
                )
            }
        }
    }
    public enum SellCryptoScreen {
        public static let from = NSLocalizedString(
            "From: My %@ Trading Account",
            comment: "Sell Crypto: `from` wallet format"
        )
        public static let to = NSLocalizedString(
            "To: My %@ Account",
            comment: "Sell Crypto: `to` wallet format"
        )
        public static let titlePrefix = NSLocalizedString(
            "Sell",
            comment: "Sell Crypto screen title prefix"
        )
        public static let ctaButton = NSLocalizedString(
            "Continue",
            comment: "Sell Crypto Screen - CTA button"
        )
        public static let available = NSLocalizedString(
            "Available",
            comment: "Sell Crypto Screen - Available balance title"
        )
        public static let useMax = NSLocalizedString(
            "Sell Max",
            comment: "Simple Buy: Sell Crypto Screen - Amount too high suffix"
        )
    }
    public enum IntroScreen {
        public enum BuyCard {
            public static let title = NSLocalizedString(
                "Own Crypto in a Few Minutes",
                comment: "Simple Buy Intro Screen - buy crypto card: title label"
            )
            public static let description = NSLocalizedString(
                "Verify your identity and buy crypto with the fastest experience in the market.",
                comment: "Simple Buy Intro Screen - buy crypto card: description label"
            )
        }
        public static let title = NSLocalizedString(
            "Welcome to Blockchain.com",
            comment: "Simple Buy Intro Screen - title label"
        )
        public static let continueButton = NSLocalizedString(
            "Buy Crypto Now",
            comment: "Simple Buy Intro Screen: Buy CTA button"
        )
        public static let skipButton = NSLocalizedString(
            "Skip",
            comment: "Simple Buy Intro Screen: Skip button"
        )
    }

    public enum OrderState {
        public static let waitingOnFunds = NSLocalizedString(
            "Waiting on Funds",
            comment: "Simple Buy Order State: Waiting on Funds"
        )
        public static let pending = NSLocalizedString(
            "Pending",
            comment: "Simple Buy Order State: Pending"
        )
        public static let cancelled = NSLocalizedString(
            "Cancelled",
            comment: "Simple Buy Order State: Cancelled"
        )
        public static let expired = NSLocalizedString(
            "Expired",
            comment: "Simple Buy Order State: Expired"
        )
        public static let failed = NSLocalizedString(
            "Failed",
            comment: "Simple Buy Order State: Failed"
        )
        public static let finished = NSLocalizedString(
            "Finished",
            comment: "Simple Buy Order State: Finished"
        )
    }

    public enum TransferDetails {

        public enum Funds {
            public enum Title {
                public static let addBankPrefix = NSLocalizedString(
                    "Add a",
                    comment: "Add"
                )
                public static let addBankSuffix = NSLocalizedString(
                    "Bank",
                    comment: "Bank"
                )
                public static let depositPrefix = NSLocalizedString(
                    "Deposit",
                    comment: "Deposit"
                )
            }
            public enum Notice {
                public enum BankTransferOnly {
                    public static let title = NSLocalizedString(
                        "Bank Transfers Only",
                        comment: "Bank Transfers Only"
                    )
                    public static let description = NSLocalizedString(
                        "Please do not send any funds via ACH. A real bank transfer must be sent",
                        comment: "Please do not send any funds via ACH. A real bank transfer must be sent"
                    )
                }
                public enum ProcessingTime {
                    public static let title = NSLocalizedString(
                        "Processing Time",
                        comment: "Processing Time"
                    )
                    
                    public enum Description {
                        public static let EUR = NSLocalizedString(
                            "Funds will be credited to your EUR wallet as soon as we receive them. SEPA transfers usually take around 1 business day to reach us.",
                            comment: "Funds will be credited to your EUR wallet as soon as we receive them. SEPA transfers usually take around 1 business day to reach us."
                        )
                        public static let GBP = NSLocalizedString(
                            "Funds will be credited to your GBP wallet as soon as we receive them. In the UK Faster Payments Network, this can take a couple of hours.",
                            comment: "Funds will be credited to your GBP wallet as soon as we receive them. In the UK Faster Payments Network, this can take a couple of hours."
                        )
                    }

                }
                
                public static let recipientNameEUR = NSLocalizedString(
                    "Your Recipient name above must match the account holder's name on your bank account for your transfer to be successful. Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.",
                    comment: "Your Recipient name above must match the account holder's name on your bank account for your transfer to be successful. Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected."
                )
                public static let recipientNameGBPPrefix = NSLocalizedString(
                    "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.\n By depositing funds to this account, you agree to",
                    comment: "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.\n By depositing funds to this account, you agree to"
                )
                public static let termsAndConditions = NSLocalizedString(
                    "Terms & Conditions",
                    comment: "Terms & Conditions"
                )
                public static let recipientNameGBPSuffix = NSLocalizedString(
                    "of Modulr, our banking partner.",
                    comment: " , our banking partner."
                )
            }

        }
        
        public enum Title {
            public static let pendingOrderPrefix = NSLocalizedString(
                "Pending",
                comment: "Simple Buy pending order screen title prefix"
            )
            public static let pendingOrderSuffix = NSLocalizedString(
                "Buy",
                comment: "Simple Buy pending order screen title suffix"
            )
            public static let checkout = NSLocalizedString(
                "Transfer Details",
                comment: "Simple Buy checkout screen title"
            )
        }
        
        public enum Button {
            public static let ok = NSLocalizedString(
                "OK",
                comment: "Simple Buy: Transfer Details Screen - ok button"
            )
            public static let cancel = NSLocalizedString(
                "Cancel Order",
                comment: "Simple Buy: Transfer Details Screen - cancel button"
            )
        }

        public enum TermsLink {
            public enum GBP {
                public static let prefix = NSLocalizedString(
                    "By depositing funds to this account, you agree to ",
                    comment: "Simple Buy - GBP terms and conditions link prefix"
                )
                public static let link = NSLocalizedString(
                    "Terms & Conditions of Modulr",
                    comment: "Simple Buy - GBP terms and conditions link content"
                )
                public static let suffix = NSLocalizedString(
                    ", our banking partner. ",
                    comment: "Simple Buy - GBP terms and conditions link suffix"
                )
            }
        }

        public enum Summary {
            public enum PendingOrder {
                public static let prefix = NSLocalizedString(
                    "Please transfer",
                    comment: "Simple Buy - pending order details summary label"
                )
                public static let middle = NSLocalizedString(
                    "from your bank account to Blockchain.com. Once we receive the funds, we’ll create your",
                    comment: "Simple Buy - pending order details summary label"
                )
                public static let suffix = NSLocalizedString(
                    "buy order.",
                    comment: "Simple Buy - pending order details summary label"
                )
            }

            public enum AnyFiat {
                public static let prefix = NSLocalizedString(
                    "Securely transfer",
                    comment: "Simple Buy - buy summary prefix"
                )
                public static let suffix = NSLocalizedString(
                    "from your bank account to Blockchain.com. Depending on the transfer method and availability of funds, this may take up to 1 business day.",
                    comment: "Simple Buy - buy summary suffix"
                )
            }

            public enum GbpAndUsd {
                public static let prefix = NSLocalizedString(
                    "Securely transfer",
                    comment: "Simple Buy - buy summary prefix"
                )
                public static let suffix = NSLocalizedString(
                    "from your bank to Blockchain.com. Funds are generally available to trade in 1 business day.",
                    comment: "Simple Buy - buy summary suffix"
                )
            }
        }

        public static let disclaimer = NSLocalizedString(
            "Only send funds from a bank account in your name. If not, your deposit could be delayed or rejected.",
            comment: "Simple Buy - disclaimer"
        )

        public enum Cancellation {
            public static let title = NSLocalizedString(
                "Are you sure?",
                comment: "Simple buy - cancellation title"
            )
            public enum Description {
                public static let thisWillRemove = NSLocalizedString(
                    "This will remove your",
                    comment: "This will remove your"
                )
                public static let buyOrder = NSLocalizedString("Buy order.", comment: "Buy order.")
            }
            public static let no = NSLocalizedString("No", comment: "No")
            public static let yes = NSLocalizedString("Yes", comment: "Yes")
        }
    }

    public enum Checkout {
        public enum Button {
            public static let transferDetails = NSLocalizedString(
                "View Bank Transfer Details",
                comment: "Simple Buy: Order Details - transfer details button"
            )
        }
        public enum Title {
            public static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout screen Title"
            )
            public static let orderDetails = NSLocalizedString(
                "Order Details",
                comment: "Order Details screen Title"
            )
        }
        public enum Summary {
            public static let of = NSLocalizedString(
                "of",
                comment: "Simple buy checkout screen: of (e.g. 100 USD 'of' BTC)"
            )
            public enum Title {
                public static let prefix = NSLocalizedString(
                    "Please review and confirm your ",
                    comment: "Simple buy checkout screen - title prefix"
                )
                public static let suffix = NSLocalizedString(
                    " buy.",
                    comment: "Simple buy checkout screen - title suffix"
                )
            }
            public static let buyButtonPrefix = NSLocalizedString(
                "Buy ",
                comment: "Simple buy checkout screen - buy button prefix"
            )
            public static let continueButtonPrefix = NSLocalizedString(
                "OK",
                comment: "Simple buy checkout screen - continue button"
            )
            public static let completePaymentButton = NSLocalizedString(
                "Complete Payment",
                comment: "Simple buy checkout screen - complete payment button"
            )
        }

        public enum Notice {

            public static let funds = NSLocalizedString(
                "Your final amount may change due to market activity.",
                comment: "Simple buy: checkout screen notice label for funds"
            )

            public static let cards = NSLocalizedString(
                "Your final amount might change due to market activity. An initial hold period of 7 days will be applied to your funds.",
                comment: "Simple buy: checkout screen notice label for cards"
            )

            public enum BankTransfer {
                public static let prefix = NSLocalizedString(
                    "Once we receive your funds, we’ll start your",
                    comment: "Simple buy: checkout screen notice label prefix"
                )
                public static let suffix = NSLocalizedString(
                    "buy order. Note, your final amount might change to due market activity. Fees may apply.",
                    comment: "Simple buy: checkout screen notice label suffix"
                )
            }
        }

        public enum PendingOrderScreen {
            public enum Loading {
                public static let titlePrefix = NSLocalizedString(
                    "Buying",
                    comment: "Simple buy: final screen title prefix: Buying 0.00525688 BTC"
                )
                public static let subtitle = NSLocalizedString(
                    "We’re completing your purchase now.",
                    comment: "Simple buy: final screen subtitle: We’re completing your purchase now."
                )
            }
            public enum Success {
                public static let titleSuffix = NSLocalizedString(
                    "Purchased",
                    comment: "Simple buy: final screen title suffix: E.G 0.0052568 BTC Purchased"
                )
                public enum Subtitle {
                    public static let prefix = NSLocalizedString(
                        "Your",
                        comment: "Simple buy: final screen subtitle prefix: Your Asset is now available in your Wallet."
                    )
                    public static let suffix = NSLocalizedString(
                        "is now available in your Wallet.",
                        comment: "Simple buy: final screen subtitle suffix: Your Asset is now available in your Wallet."
                    )
                }
            }
            public enum Timeout {
                public static let titleSuffix = NSLocalizedString(
                    "Buy In Progress",
                    comment: "Pending active card error screen: title"
                )
                public static let subtitle = NSLocalizedString(
                    "We’ll notify you when your order is complete.",
                    comment: "Pending active card error screen: subtitle"
                )
            }

            public static let button = NSLocalizedString(
                "OK",
                comment: "Simple buy: final screen ok button"
            )
        }
    }
    
    public enum CashIntroductionScreen {
        public static let title = NSLocalizedString("Keep Cash in Your Wallet", comment: "Keep Cash in Your Wallet")
        public static let description = NSLocalizedString(
            "Verify your identity to deposit cash into your Wallet. Buy & Sell scrupto. Withdraw at anytime.",
            comment: "Verify your identity to deposit cash into your Wallet. Buy & Sell scrupto. Withdraw at anytime."
        )
        public static let notNow = NSLocalizedString("Not Now", comment: "Not Now")
        public static let verifyIdentity = NSLocalizedString("Verify Identity", comment: "Verify Identity")
        public enum List {
            public enum First {
                public static let title = NSLocalizedString("Verify Your Identity", comment: "Verify Your Identity")
                public static let description = NSLocalizedString(
                    "We need to make sure it's really you to prevent fraud by uploading an ID.",
                    comment: "We need to make sure it's really you to prevent fraud by uploading an ID."
                )
            }
            public enum Second {
                public static let title = NSLocalizedString("Deposit Cash", comment: "Deposit Cash")
                public static let description = NSLocalizedString(
                    "Transfer cash from your bank and enable your cash balances.",
                    comment: "Transfer cash from your bank and enable your cash balances."
                )
            }
            public enum Third {
                public static let title = NSLocalizedString("Buy Crypto with Cash", comment: "Buy Crypto with Cash")
                public static let description = NSLocalizedString(
                    "Use your cash wallet as a payment method to buy BTC, ETH, XLM & more.",
                    comment: "Use your cash wallet as a payment method to buy BTC, ETH, XLM & more."
                )
            }
        }
    }

    public enum KYCScreen {
        public enum Ineligible {
            public static let title = NSLocalizedString(
                "Blockchain.com Buy Coming Soon to Your Region",
                comment: "Simple Buy KYC Screen - ineligible information: title label"
            )
            public static let subtitle = NSLocalizedString(
                "Buying and selling crypto is not available in your region due to local laws. You can still use your wallet to Send, Receive and Store crypto.",
                comment: "Simple Buy KYC Screen - ineligible information: subtitle label"
            )
            public static let button = NSLocalizedString(
                "OK",
                comment: "Simple Buy KYC Screen - ineligible information: button"
            )
        }
        public enum Verifying {
            public static let title = NSLocalizedString(
                "Verifying your information",
                comment: "Simple Buy KYC Screen - verifying information: title label"
            )
            public static let subtitle = NSLocalizedString(
                "Usually takes less than a minute.",
                comment: "Simple Buy KYC Screen - verifying information: subtitle label"
            )
        }
        public enum ManualReview {
            public static let title = NSLocalizedString(
                "Manual Review Required",
                comment: "Simple Buy KYC Screen - manual review: title label"
            )
            public static let subtitle = NSLocalizedString(
                "You’ve successfully submitted your application. A Blockchain Support Member will review your information.",
                comment: "Simple Buy KYC Screen - manual review: subtitle label"
            )
        }
        public enum PendingReview {
            public static let title = NSLocalizedString(
                "Pending Review",
                comment: "Simple Buy KYC Screen - pending review: title label"
            )
            public static let subtitle = NSLocalizedString(
                "You’ve successfully submitted your application. A Blockchain Support Member will review your information.",
                comment: "Simple Buy KYC Screen - pending review: subtitle label"
            )
        }
        public static let title = NSLocalizedString(
            "KYC Status",
            comment: "Simple Buy KYC Screen - title label"
        )
        public static let button = NSLocalizedString(
            "Continue",
            comment: "Simple Buy KYC Screen - button label"
        )
    }
}

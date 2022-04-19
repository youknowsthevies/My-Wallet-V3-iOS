// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    enum CardIssuing {
        enum CardType {
            enum Virtual {
                static let title = NSLocalizedString(
                    "Virtual",
                    comment: "Card Issuing: Type Virtual title"
                )

                static let description = NSLocalizedString(
                    "Our digital only card, use instantly for online payments.",
                    comment: "Card Issuing: Type Virtual description"
                )
            }
        }

        enum Navigation {
            static let title = NSLocalizedString(
                "Blockchain Card",
                comment: "Card Issuing: Navigation title"
            )
        }

        enum Order {
            enum Intro {
                static let title = NSLocalizedString(
                    "Your Gateway To The Blockchain Debit Card",
                    comment: "Card Issuing: Order screen title"
                )

                static let caption = NSLocalizedString(
                    "A card that lets you spend and earn in crypto right from your Blockchain account.",
                    comment: "Card Issuing: Order screen caption"
                )

                enum Button {
                    enum Title {
                        static let order = NSLocalizedString(
                            "Order My Card",
                            comment: "Card Issuing: Order button"
                        )

                        static let link = NSLocalizedString(
                            "Already Have A Card? Link It Here",
                            comment: "Card Issuing: Link a card button"
                        )
                    }
                }
            }

            enum Selection {
                enum Navigation {
                    static let title = NSLocalizedString(
                        "Select Your Card",
                        comment: "Card Issuing: Select your card navigation title"
                    )
                }

                enum Button {
                    enum Title {
                        static let details = NSLocalizedString(
                            "See Card Details",
                            comment: "Card Issuing: See card details button"
                        )

                        static let create = NSLocalizedString(
                            "Create Card",
                            comment: "Card Issuing: Create card button"
                        )
                    }
                }
            }

            enum Details {
                enum Navigation {
                    static let title = NSLocalizedString(
                        "Card Details",
                        comment: "Card Issuing: Card Details title"
                    )
                }

                enum Benefits {
                    static let title = NSLocalizedString(
                        "Card Benefits",
                        comment: "Card Issuing: Card Benefits Details Section"
                    )

                    static let rewards = NSLocalizedString(
                        "Cashback Rewards",
                        comment: "Card Issuing: Cashback Rewards"
                    )
                }

                enum Fees {
                    static let title = NSLocalizedString(
                        "Fees",
                        comment: "Card Issuing: Fees Details Section"
                    )

                    static let annual = NSLocalizedString(
                        "Annual Fee",
                        comment: "Card Issuing: Annual Fee"
                    )

                    static let delivery = NSLocalizedString(
                        "Delivery Fee",
                        comment: "Card Issuing: Delivery Fee"
                    )

                    static let noCharge = NSLocalizedString(
                        "No Charge",
                        comment: "Card Issuing: No Charge"
                    )
                }

                enum Card {
                    static let title = NSLocalizedString(
                        "Card",
                        comment: "Card Issuing: Card Details Section"
                    )

                    static let contactless = NSLocalizedString(
                        "Contactless Payment",
                        comment: "Card Issuing: Contactless Payment"
                    )

                    static let consumerFinancialProtectionBureau = NSLocalizedString(
                        "Consumer Financial Protection Bureau",
                        comment: "Card Issuing: Consumer Financial Protection Bureau"
                    )

                    static let shortFormDisclosure = NSLocalizedString(
                        "Short Form Disclosure",
                        comment: "Card Issuing: Short Form Disclosure"
                    )

                    static let blockchainTermsAndConditions = NSLocalizedString(
                        "Blockchain.com Terms & Conditions",
                        comment: "Card Issuing: Blockchain.com Terms & Conditions"
                    )

                    static let termsAndConditions = NSLocalizedString(
                        "Terms & Conditions",
                        comment: "Card Issuing: Terms & Conditions"
                    )
                }
            }

            enum Processing {
                enum Success {
                    static let title = NSLocalizedString(
                        "Card Successfully Created!",
                        comment: "Card Issuing: Card Successfully Created!"
                    )

                    static let caption = NSLocalizedString(
                        "Welcome to the club, to view your card dashboard please press Continue below.",
                        comment: "Card Issuing: Order success caption"
                    )
                }

                enum Error {
                    static let title = NSLocalizedString(
                        "Failed To Create Your Card",
                        comment: "Card Issuing: Card Creation Failed"
                    )

                    static let caption = NSLocalizedString(
                        """
                        Sometimes this can happen when the systems are bogged down. \
                        You can try again by clicking `Retry` below or come back again in a bit.
                        """,
                        comment: "Card Issuing: Card Creation Error message"
                    )

                    static let retry = NSLocalizedString(
                        "Retry",
                        comment: "Card Issuing: Card Creation Error Retry Button"
                    )

                    static let cancelGoBack = NSLocalizedString(
                        "Cancel & Go Back",
                        comment: "Card Issuing: Card Creation Error Cancel & Go Back Button"
                    )
                }

                enum Processing {
                    static let title = NSLocalizedString(
                        "Processing...",
                        comment: "Card Issuing: Card Creation Processing"
                    )
                }
            }

            enum Manage {
                enum Button {
                    static let manage = NSLocalizedString(
                        "Manage",
                        comment: "Card Issuing: Manage"
                    )

                    static let topUp = NSLocalizedString(
                        "Top Up",
                        comment: "Card Issuing: Top Up"
                    )

                    enum ChoosePaymentMethod {
                        static let title = NSLocalizedString(
                            "Choose Payment Method",
                            comment: "Card Issuing: Choose payment method"
                        )
                        static let caption = NSLocalizedString(
                            "Fund your card purchases",
                            comment: "Card Issuing: Choose payment method caption"
                        )
                    }
                }

                enum RecentTransactions {
                    static let title = NSLocalizedString(
                        "Recent Transactions",
                        comment: "Card Issuing: Recent Transactions"
                    )
                    static let placeholder = NSLocalizedString(
                        "Your most recent purchases will show up here",
                        comment: "Card Issuing: placeholder when no transaction"
                    )
                }
            }
        }
    }
}

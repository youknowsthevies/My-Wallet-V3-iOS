// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants.CardIssuing {

    enum Order {
        enum Intro {
            static let title = NSLocalizedString(
                "Get the Blockchain.com\nVisa Card",
                comment: "Card Issuing: Order screen title"
            )

            static let caption = NSLocalizedString(
                "Spend your crypto or cash without fees.\nEarn 1% back in crypto.",
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

            static let acceptTerms = NSLocalizedString(
                "I agree to Blockchain.com's Terms of Service",
                comment: "Card Issuing: Accept Terms & Conditions"
            )

            enum Button {
                enum Title {
                    static let details = NSLocalizedString(
                        "See Card Details ->",
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

            enum Rewards {
                static let title = NSLocalizedString(
                    "Crypto Rewards",
                    comment: "Card Issuing: Cashback Rewards title"
                )

                static let description = NSLocalizedString(
                    "Earn 1% back in crypto rewards on all your purchases.",
                    comment: "Card Issuing: Cashback Rewards description"
                )
            }

            enum Fees {
                static let title = NSLocalizedString(
                    "No Fees",
                    comment: "Card Issuing: Fees item"
                )

                static let description = NSLocalizedString(
                    "No sign up fees. No annual fees. No transaction fees.",
                    comment: "Card Issuing: Fees description"
                )
            }

            enum Legal {
                static let navigationTitle = NSLocalizedString(
                    "Legal Disclosures",
                    comment: "Card Issuing: Legal Navigation Title"
                )

                static let title = NSLocalizedString(
                    "The Legal Stuff",
                    comment: "Card Issuing: Legal Title"
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

            enum Processing {
                static let title = NSLocalizedString(
                    "Processing...",
                    comment: "Card Issuing: Card Creation Processing"
                )
            }
        }
    }
}

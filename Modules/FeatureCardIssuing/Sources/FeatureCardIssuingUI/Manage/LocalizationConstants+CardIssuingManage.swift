// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants.CardIssuing {

    public enum Manage {

        static let title = NSLocalizedString(
            "My Cards",
            comment: "Card Issuing: title My Cards"
        )

        enum Activity {

            enum Button {

                static let help = NSLocalizedString(
                    "Need Help? Contact Support",
                    comment: "Card Issuing: Help Button"
                )
            }

            static let transactionDetails = NSLocalizedString(
                "Transaction Details",
                comment: "Card Issuing: Transaction Details"
            )

            static let status = NSLocalizedString(
                "Status",
                comment: "Card Issuing: Transaction Status"
            )

            static let transactionListTitle = NSLocalizedString(
                "Transactions",
                comment: "Card Issuing: Transaction List Title"
            )

            enum DetailSections {

                static let merchant = NSLocalizedString(
                    "Merchant",
                    comment: "Card Issuing: Merchant"
                )

                static let dateTime = NSLocalizedString(
                    "Date & Time",
                    comment: "Card Issuing: Date & Time"
                )

                static let paymentMethod = NSLocalizedString(
                    "Payment Method",
                    comment: "Card Issuing: Payment Method"
                )
            }
        }

        enum Transaction {

            enum Status {

                static let pending = NSLocalizedString(
                    "Pending",
                    comment: "Card Issuing: Transaction Status Pending"
                )

                static let settled = NSLocalizedString(
                    "Settled",
                    comment: "Card Issuing: Transaction Status Settled"
                )

                static let failed = NSLocalizedString(
                    "Failed",
                    comment: "Card Issuing: Transaction Status Failed"
                )
            }
        }

        enum Button {
            static let manage = NSLocalizedString(
                "Manage Card",
                comment: "Card Issuing: Manage"
            )

            static let addFunds = NSLocalizedString(
                "Add Funds",
                comment: "Card Issuing: Add Funds"
            )

            static let changeSource = NSLocalizedString(
                "Change Source",
                comment: "Card Issuing: Change Source"
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

        enum Card {
            static let validThru = NSLocalizedString(
                "Valid Thru",
                comment: "Card Issuing: Credit Card Placeholder Valid Thru"
            )
            static let cvv = NSLocalizedString(
                "CVV",
                comment: "Card Issuing: Credit Card Placeholder CVV"
            )
        }

        public enum SourceAccount {
            public static let title = NSLocalizedString(
                "Spend from",
                comment: "Card Issuing: Linked Account Spend From"
            )

            public static let cashBalance = NSLocalizedString(
                "Cash Balance",
                comment: "Card Issuing: Linked Account Cash Balance"
            )
        }

        enum TopUp {
            enum AddFunds {
                static let title = NSLocalizedString(
                    "Add Funds",
                    comment: "Card Issuing: Add Funds"
                )
                static let caption = NSLocalizedString(
                    "Fund your current account",
                    comment: "Card Issuing: Add funds caption"
                )
            }

            enum Swap {
                static let title = NSLocalizedString(
                    "Swap",
                    comment: "Card Issuing: Swap"
                )
                static let caption = NSLocalizedString(
                    "Exchange for another crypto",
                    comment: "Card Issuing: Swap caption"
                )
            }
        }

        enum Details {
            static let title = NSLocalizedString(
                "Manage Your Card",
                comment: "Card Issuing: Manage your card title"
            )
            static let virtualCard = NSLocalizedString(
                "Virtual Card",
                comment: "Card Issuing: Virtual Card"
            )
            static let physicalCard = NSLocalizedString(
                "Physical Card",
                comment: "Card Issuing: Physical Card"
            )
            static let addToAppleWallet = NSLocalizedString(
                "Add to Apple Wallet",
                comment: "Card Issuing: Add To Apple Wallet"
            )
            static let delete = NSLocalizedString(
                "Close Card",
                comment: "Card Issuing: Close Card"
            )

            enum Lock {
                static let title = NSLocalizedString(
                    "Lock Card",
                    comment: "Card Issuing: Lock Card Title"
                )
                static let subtitle = NSLocalizedString(
                    "Temporarily lock your card",
                    comment: "Card Issuing: Lock Card Description"
                )
            }

            enum Support {
                static let title = NSLocalizedString(
                    "Support",
                    comment: "Card Issuing: Support Button Title"
                )
                static let subtitle = NSLocalizedString(
                    "Get help with card related issues",
                    comment: "Card Issuing: Support Button Description"
                )
            }

            enum Close {
                static let title = NSLocalizedString(
                    "Close ***%@?",
                    comment: "Card Issuing: Close {{Card Name}}"
                )

                static let message = NSLocalizedString(
                    """
                    Are you sure? Once confirmed this action cannot be undone. \
                    If you do want to permanently close this card, click the big red button.
                    """,
                    comment: "Card Issuing: Close Card Warning Message"
                )

                static let confirmation = NSLocalizedString(
                    "Yes Delete Card",
                    comment: "Card Issuing: Confirm Delete Button"
                )
            }
        }
    }
}

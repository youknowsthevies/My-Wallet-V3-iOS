// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum WithdrawalLock {
        static let onHoldTitle = NSLocalizedString(
            "On Hold",
            comment: "Withdrawal Locks: On Hold Title"
        )

        static let onHoldAmountTitle = NSLocalizedString(
            "%@ On Hold",
            comment: "Withdrawal Locks: On Hold Title with the amount"
        )

        // swiftlint:disable line_length
        static let holdingPeriodDescription = NSLocalizedString(
            "Newly added funds are subject to a holding period. You can transfer between your Trading, Rewards, and Exchange accounts in the meantime.",
            comment: "Withdrawal Locks: Holding period description"
        )

        static let noLocks = NSLocalizedString(
            "You do not have any pending withdrawal locks.",
            comment: "Withdrawal Locks: Held Until section title"
        )

        static let heldUntilTitle = NSLocalizedString(
            "Held Until",
            comment: "Withdrawal Locks: Held Until section title"
        )

        static let amountTitle = NSLocalizedString(
            "Amount",
            comment: "Withdrawal Locks: Amount section title"
        )

        static let availableToWithdrawTitle = NSLocalizedString(
            "Available to Withdraw",
            comment: "Withdrawal Locks: Available to Withdraw title"
        )

        static let learnMoreButtonTitle = NSLocalizedString(
            "Learn More",
            comment: "Withdrawal Locks: Learn More button title"
        )

        static let learnMoreTitle = NSLocalizedString(
            "Learn more ->",
            comment: "Withdrawal Locks: Learn More title"
        )

        static let seeDetailsButtonTitle = NSLocalizedString(
            "See Details",
            comment: "Withdrawal Locks: See Details button title"
        )

        static let confirmButtonTitle = NSLocalizedString(
            "I Understand",
            comment: "Withdrawal Locks: I Understand button title"
        )
    }
}

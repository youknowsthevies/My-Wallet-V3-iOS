// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum Transaction {
        public enum TargetSource {
            public enum Radio { }
            public enum Card { }
        }
        public enum Confirmation {
            public enum Error { }
        }
        public enum Receive {
            public enum KYC { }
        }
        public enum Send {
            public enum AmountPresenter {
                public enum LimitView { }
            }
            public enum Completion {
                public enum Pending { }
                public enum Success { }
                public enum Failure { }
            }
        }
        public enum Withdraw {
            public enum Completion {
                public enum Pending { }
                public enum Success { }
                public enum Failure { }
            }
        }
        public enum Deposit {
            public enum Completion {
                public enum Pending { }
                public enum Success { }
                public enum Failure { }
            }
        }
        public enum Swap {
            public enum KYC { }
            public enum Completion {
                public enum Pending { }
                public enum Success { }
                public enum Failure { }
            }
            public enum AmountPresenter {
                public enum LimitView { }
            }
        }
        public enum Error {}
    }
}

extension LocalizationConstants.Transaction.TargetSource.Radio {
    public static let accountEndingIn = NSLocalizedString("Account Ending in", comment: "Account Ending in")
    public static let minimum = NSLocalizedString("Minimum", comment: "Minimum")
    public static let free = NSLocalizedString("Free", comment: "Free")
    public static let fee = NSLocalizedString("Fee", comment: "Fee")
}

extension LocalizationConstants.Transaction.Swap.AmountPresenter.LimitView {
    public static let useMin = NSLocalizedString(
        "The minimum swap is %@",
        comment: "The minimum swap is"
    )
    public static let useMax = NSLocalizedString(
        "You can swap up to %@",
        comment: "You can swap up to"
    )
}

public extension LocalizationConstants.Transaction.Receive.KYC {

    static let title = NSLocalizedString(
        "Verify to use the Trading Account",
        comment: ""
    )
    static let subtitle = NSLocalizedString(
        "Get access to the Trading Account in seconds by completing your profile and getting Silver access.",
        comment: ""
    )
    static let card1Title = NSLocalizedString(
        "Verify Your Email",
        comment: ""
    )
    static let card1Subtitle = NSLocalizedString(
        "Confirm your email address to protect your Blockchain.com Wallet.",
        comment: ""
    )
    static let card2Title = NSLocalizedString(
        "Add Your Name & Address",
        comment: ""
    )
    static let card2Subtitle = NSLocalizedString(
        "We need to know your name and address to comply with local laws.",
        comment: ""
    )
    static let card3Title = NSLocalizedString(
        "Use the Trading Account",
        comment: ""
    )
    static let card3Subtitle = NSLocalizedString(
        "Send, Receive, Buy and Swap cryptocurrencies with your Trading Account.",
        comment: ""
    )
    static let verifyNow = NSLocalizedString(
        "Verify Now",
        comment: ""
    )

}

public extension LocalizationConstants.Transaction.Swap.KYC {

    static let overSilverLimitWarning = NSLocalizedString(
        "Tap here to upgrade your profile and swap this amount.",
        comment: "Tap here to upgrade your profile and swap this amount."
    )
    static let title = NSLocalizedString(
        "Verify Your Email & Swap Today.",
        comment: ""
    )
    static let subtitle = NSLocalizedString(
        "Get access to swap in seconds by completing your profile and getting Silver access.",
        comment: ""
    )
    static let card1Title = NSLocalizedString(
        "Verify Your Email",
        comment: ""
    )
    static let card1Subtitle = NSLocalizedString(
        "Confirm your email address to protect your Blockchain.com Wallet.",
        comment: ""
    )
    static let card2Title = NSLocalizedString(
        "Add Your Name and Address",
        comment: ""
    )
    static let card2Subtitle = NSLocalizedString(
        "We need to know your name and address to comply with local laws.",
        comment: ""
    )
    static let card3Title = NSLocalizedString(
        "Start Swapping",
        comment: ""
    )
    static let card3Subtitle = NSLocalizedString(
        "Instantly exchange your crypto.",
        comment: ""
    )
    static let verifyNow = NSLocalizedString(
        "Verify Now",
        comment: ""
    )
}

public extension LocalizationConstants.Transaction {

    static let viewActivity = NSLocalizedString("View Activity", comment: "View Activity")
    static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
    static let sell = NSLocalizedString("Sell", comment: "Sell")
    static let send = NSLocalizedString("Send", comment: "Send")
    static let swap = NSLocalizedString("Swap", comment: "Swap")
    static let withdraw = NSLocalizedString("Withdraw", comment: "Withdraw")
    static let buy = NSLocalizedString("Buy", comment: "Buy")

    static let max = NSLocalizedString("Max", comment: "Max")

    static let next = NSLocalizedString(
        "Next",
        comment: "Next"
    )
    static let receive = NSLocalizedString(
        "Receive",
        comment: "Receive"
    )
    static let available = NSLocalizedString(
        "Available",
        comment: "Available"
    )
    static let networkFee = NSLocalizedString("Network Fee", comment: "Network Fee")
    static let newSwap = NSLocalizedString(
        "New Swap",
        comment: "New Swap"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    static let selectAWallet = NSLocalizedString(
        "Select a Wallet",
        comment: "Select a Wallet"
    )
    static let orSelectAWallet = NSLocalizedString(
        "or Select a Wallet",
        comment: "Select a Wallet"
    )
}

public extension LocalizationConstants.Transaction.Withdraw {
    static let withdraw = NSLocalizedString(
        "Withdraw",
        comment: "Withdraw"
    )
    static let withdrawTo = NSLocalizedString(
        "Withdraw to...",
        comment: "Withdraw to..."
    )
    static let account = NSLocalizedString("Account", comment: "Account")

    // swiftlint:disable line_length
    static let confirmationDisclaimer = NSLocalizedString(
        "Your final amount might change due to market activity. For your security, buy orders with a bank account are subject up to a 14 day holding period. You can Swap or Sell during this time. We will notify you once the funds are fully available.",
        comment: "Your final amount might change due to market activity. For your security, buy orders with a bank account are subject up to a 14 day holding period. You can Swap or Sell during this time. We will notify you once the funds are fully available."
    )
}

public extension LocalizationConstants.Transaction.Deposit {
    static let linkedBanks = NSLocalizedString(
        "Linked Banks",
        comment: "Linked Banks"
    )
    static let add = NSLocalizedString("Add", comment: "Add")

    static let dailyLimit = NSLocalizedString("Daily Limit", comment: "Daily Limit")

    static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
}

public extension LocalizationConstants.Transaction.Send {
    static let send = NSLocalizedString(
        "Send",
        comment: "Send"
    )
    static let sendMax = NSLocalizedString(
        "Send Max",
        comment: "Send Max"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    static let networkFee = NSLocalizedString(
        "Network Fee",
        comment: "Network Fee"
    )
    static let regular = NSLocalizedString(
        "Regular",
        comment: "Regular"
    )
    static let priority = NSLocalizedString(
        "Priority",
        comment: "Priority"
    )
    static let custom = NSLocalizedString(
        "Custom",
        comment: "Custom"
    )
    static let min = NSLocalizedString(
        "Min",
        comment: "Abbreviation for minutes"
    )
    static let minutes = NSLocalizedString(
        "Minutes",
        comment: "Minutes"
    )
}

public extension LocalizationConstants.Transaction.TargetSource.Card {
    static let internalSendOnly = NSLocalizedString("Internal Send Only", comment: "Internal Send Only")
    // swiftlint:disable line_length
    static let description = NSLocalizedString(
        "At this time you can only transfer %@ from your %@ Trading Account to your %@ Private Key Wallets. Once %@ is in your Private Key Wallet you can transfer to external addresses.",
        comment: "At this time you can only transfer %@ from your %@ Trading Account to your %@ Private Key Wallets. Once %@ is in your Private Key Wallet you can transfer to external addresses."
    )
}

public extension LocalizationConstants.Transaction.Send.AmountPresenter.LimitView {
    static let useMin = NSLocalizedString(
        "The minimum send is %@",
        comment: "The minimum send is"
    )
    static let useMax = NSLocalizedString(
        "You can send up to %@",
        comment: "You can send up to"
    )
}

public extension LocalizationConstants.Transaction.Swap {
    static let title = swap
    static let swap = NSLocalizedString(
        "Swap",
        comment: "Swap"
    )
    static let swapMax = NSLocalizedString(
        "Swap Max",
        comment: "Swap Max"
    )
    static let confirmationDisclaimer = NSLocalizedString(
        "The amounts you send and receive may change slightly due to market activity. Once an order starts, we are unable to stop it.",
        comment: "Confirmation screen disclaimer."
    )
    static let sourceAccountPicketSubtitle = NSLocalizedString(
        "Which wallet do you want to Swap from?",
        comment: "Swap Source Account Picket Header Subtitle"
    )
    static let destinationAccountPicketSubtitle = NSLocalizedString(
        "Which crypto do you want to Swap for?",
        comment: "Swap Destination Account Picket Header Subtitle"
    )
    static let swapAForB = NSLocalizedString(
        "Swap %@ for %@",
        comment: "Swap %@ for %@"
    )
    static let send = NSLocalizedString(
        "Send %@",
        comment: "Send %@"
    )
    static let sell = NSLocalizedString(
        "Sell %@",
        comment: "Sell %@"
    )
    static let deposit = NSLocalizedString(
        "Confirm Transfer",
        comment: "Confirm Transfer"
    )
    static let newSwapDisclaimer = NSLocalizedString(
        "Confirm the wallet you want to Swap from and choose the wallet you want to Receive into.",
        comment: "Confirm the wallet you want to Swap from and choose the wallet you want to Receive into."
    )
}

// MARK: - Withdraw Pending

public extension LocalizationConstants.Transaction.Withdraw.Completion.Pending {
    static let title = NSLocalizedString("Withdrawing %@", comment: "Withdrawing %@")
    static let description = NSLocalizedString(
        "We're completing your withdraw now.",
        comment: "We're completing your withdraw now."
    )
}

public extension LocalizationConstants.Transaction.Withdraw.Completion.Success {
    static let title = NSLocalizedString("%@ Withdrawal Started", comment: "%@ Withdrawal Started")
    static let description = NSLocalizedString(
        "We are sending the cash now. Expect the cash to hit your bank on %@. Check the status of your Withdrawal at anytime from your Activity screen.",
        comment: "We are sending the cash now. Expect the cash to hit your bank on %@. Check the status of your Withdrawal at anytime from your Activity screen."
    )
}

public extension LocalizationConstants.Transaction.Withdraw.Completion.Failure {
    static let title = NSLocalizedString(
        "Oops! Something Went Wrong.",
        comment: "Oops! Something Went Wrong."
    )
    static let description = NSLocalizedString(
        "Don’t worry. Your funds are safe. Please try again or contact our Suppport Team for help.",
        comment: "Don’t worry. Your funds are safe. Please try again or contact our Suppport Team for help."
    )
}

// MARK: - Deposit Pending

public extension LocalizationConstants.Transaction.Deposit.Completion.Pending {
    static let title = NSLocalizedString("Depositing %@", comment: "Depositing %@")
    static let description = NSLocalizedString(
        "We're completing your deposit now.",
        comment: "We're completing your deposit now."
    )
}

public extension LocalizationConstants.Transaction.Deposit.Completion.Success {
    static let title = NSLocalizedString("%@ Deposited", comment: "%@ Deposited")
    static let description = NSLocalizedString(
        "While we wait for your bank to send the cash, here’s early access to %@ in your %@ Cash Account so you can buy crypto right now. Your funds will be available to withdraw once the bank transfer is complete on %@",
        comment: "While we wait for your bank to send the cash, here’s early access to $@ in your %@ Cash Account so you can buy crypto right now. Your funds will be available to withdraw once the bank transfer is complete on %@"
    )
}

public extension LocalizationConstants.Transaction.Deposit.Completion.Failure {
    static let title = NSLocalizedString(
        "Oops! Something Went Wrong.",
        comment: "Oops! Something Went Wrong."
    )
    static let description = NSLocalizedString(
        "Don’t worry. Your funds are safe. Please try again or contact our Suppport Team for help.",
        comment: "Don’t worry. Your funds are safe. Please try again or contact our Suppport Team for help."
    )
}

// MARK: - Send Pending

public extension LocalizationConstants.Transaction.Send.Completion.Pending {
    static let title = NSLocalizedString(
        "Sending %@",
        comment: "Sending %@"
    )
    static let description = NSLocalizedString(
        "We're sending your transaction now.",
        comment: "We're sending your transaction now."
    )
}

public extension LocalizationConstants.Transaction.Send.Completion.Success {
    static let title = NSLocalizedString(
        "%@ Sent",
        comment: "Swap Complete"
    )
    static let description = NSLocalizedString(
        "Your %@ has been successfully sent.",
        comment: "Your %@ has been successfully sent."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )
}

public extension LocalizationConstants.Transaction.Send.Completion.Failure {
    static let title = NSLocalizedString(
        "Oops! Something Went Wrong.",
        comment: "Oops! Something Went Wrong."
    )
    static let description = NSLocalizedString(
        "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help.",
        comment: "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )

    static let insufficientFundsForFees = NSLocalizedString(
        "Not enough %@ in your wallet to send with current network fees.",
        comment: ""
    )

    static let underMinLimit = NSLocalizedString(
        "Minimum send of %@ required.",
        comment: ""
    )

    static let overGoldTierLimit = NSLocalizedString(
        "You can send up to %1$s today.",
        comment: ""
    )

    static let overSilverTierLimit = NSLocalizedString(
        "Please upgrade your profile to send this amount.",
        comment: ""
    )
}

// MARK: - Swap Pending

public extension LocalizationConstants.Transaction.Swap.Completion.Pending {
    static let title = NSLocalizedString(
        "Swapping %@ for %@",
        comment: "Swapping %@ for %@"
    )
    static let description = NSLocalizedString(
        "We're completing your swap now.",
        comment: "We're completing your swap now."
    )
}

public extension LocalizationConstants.Transaction.Swap.Completion.Success {
    static let title = NSLocalizedString(
        "Swap Complete",
        comment: "Swap Complete"
    )
    static let description = NSLocalizedString(
        "Your %@ is now available in your Wallet.",
        comment: "Your %@ is now available in your Wallet."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )
}

public extension LocalizationConstants.Transaction.Swap.Completion.Failure {
    static let title = NSLocalizedString(
        "Oops! Something Went Wrong.",
        comment: "Oops! Something Went Wrong."
    )
    static let description = NSLocalizedString(
        "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help.",
        comment: "Don’t worry. Your crypto is safe. Please try again or contact our Suppport Team for help."
    )
    static let action = NSLocalizedString(
        "OK",
        comment: "OK"
    )

    static let insufficientFundsForFees = NSLocalizedString(
        "Not enough %@ in your wallet to swap with current network fees.",
        comment: ""
    )

    static let underMinLimit = NSLocalizedString(
        "Minimum swap of %@ required.",
        comment: ""
    )

    static let overGoldTierLimit = NSLocalizedString(
        "You can swap up to %1$s today.",
        comment: ""
    )

    static let overSilverTierLimit = NSLocalizedString(
        "Please upgrade your profile to swap this amount.",
        comment: ""
    )
}

public extension LocalizationConstants.Transaction.Confirmation.Error {
    static let title = NSLocalizedString("Error", comment: "Error")
    static let insufficientFunds = NSLocalizedString(
        "You have insufficient funds in this account to process this transaction",
        comment: ""
    )
    static let insufficientGas = NSLocalizedString(
        "You do not have enough ETH to process this transaction.",
        comment: ""
    )
    static let optionInvalid = NSLocalizedString(
        "Please ensure you've agreed to our Terms.",
        comment: ""
    )
    static let invoiceExpired = NSLocalizedString(
        "BitPay Invoice Expired",
        comment: ""
    )
    static let underMinLimit = NSLocalizedString(
        "%@ Min",
        comment: ""
    )
    static let underMinBitcoinFee = NSLocalizedString(
        "Minimum 1 sat/byte required",
        comment: ""
    )
    static let invalidAmount = NSLocalizedString(
        "Invalid fee",
        comment: ""
    )
    static let transactionInFlight = NSLocalizedString(
        "A transaction is already in progress",
        comment: ""
    )
    static let pendingOrderLimitReached = NSLocalizedString(
        "You have 1 Swap in-progress. Once that completes, create a New Swap.",
        comment: ""
    )
    static let generic = NSLocalizedString(
        "An unexpected error has occurred. Please try again.",
        comment: ""
    )
    static let overMaximumLimit = NSLocalizedString(
        "Maximum limit exceeded",
        comment: ""
    )
}

public extension LocalizationConstants.Transaction.Confirmation {
    static let price = NSLocalizedString(
        "%@ Price",
        comment: "%@ Price"
    )
    static let total = NSLocalizedString(
        "Total",
        comment: "Total"
    )
    static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    static let transactionFee = NSLocalizedString(
        "Transaction Fee",
        comment: "Network Fee"
    )
    static let networkFee = NSLocalizedString(
        "%@ Network Fee",
        comment: "%@ Network Fee"
    )
    static let exchangeRate = NSLocalizedString(
        "Exchange Rate",
        comment: "Exchange Rate"
    )
    static let fundsArrivalDate = NSLocalizedString(
        "Funds Will Arrive",
        comment: "Funds Will Arrive"
    )
    static let description = NSLocalizedString(
        "Description",
        comment: "Description"
    )
    static let memo = NSLocalizedString(
        "Memo",
        comment: "Memo"
    )
    static let confirm = NSLocalizedString(
        "Confirm",
        comment: "Confirm"
    )
    static let cancel = NSLocalizedString(
        "Cancel",
        comment: "Cancel"
    )
    static func transactionFee(feeType: String) -> String {
        let format = NSLocalizedString(
            "Fee - %@",
            comment: "Fee"
        )
        return String(format: format, feeType)
    }
    static let remainingTime = NSLocalizedString(
        "Remaining Time",
        comment: "Remaining Time"
    )
}

public extension LocalizationConstants.Transaction.Error {
    static let title = NSLocalizedString("Error", comment: "Error")
    static let insufficientFunds = NSLocalizedString(
        "You have insufficient funds in this account to process this transaction",
        comment: ""
    )
    static let insufficientGas = NSLocalizedString(
        "You do not have enough ETH to process this transaction.",
        comment: ""
    )
    static let addressIsContract = NSLocalizedString(
        "Address is not a user address",
        comment: ""
    )
    static let optionInvalid = NSLocalizedString(
        "Please ensure you've agreed to our Terms.",
        comment: ""
    )
    static let invoiceExpired = NSLocalizedString(
        "BitPay Invoice Expired",
        comment: ""
    )
    static let underMinLimitGeneric = NSLocalizedString(
        "Minimum amount required.",
        comment: ""
    )
    static let underMinBitcoinFee = NSLocalizedString(
        "Minimum 1 sat/byte required",
        comment: ""
    )
    static let invalidAmount = NSLocalizedString(
        "Invalid fee",
        comment: ""
    )
    static let transactionInFlight = NSLocalizedString(
        "A transaction is already in progress",
        comment: ""
    )
    static let pendingOrderLimitReached = NSLocalizedString(
        "You have 1 Swap in-progress. Once that completes, create a New Swap.",
        comment: ""
    )
    static let generic = NSLocalizedString(
        "An unexpected error has occurred. Please try again.",
        comment: ""
    )
    static let errorCode = NSLocalizedString(
        "Error Code: %@",
        comment: ""
    )
    static let overMaximumLimit = NSLocalizedString(
        "Maximum limit exceeded",
        comment: ""
    )
    static let invalidPassword = NSLocalizedString(
        "Password is incorrect.",
        comment: ""
    )
    static let invalidAddress = NSLocalizedString(
        "Not a valid address.",
        comment: ""
    )
    static let insufficientFundsForFees = NSLocalizedString(
        "Not enough %@ in your wallet to send with current network fees.",
        comment: ""
    )

    // MARK: - Transaction Flow Pending Error Descriptions

    static let unknownError = NSLocalizedString(
        "Oops! Something went wrong. Please try again.",
        comment: "Oops! Something went wrong. Please try again."
    )

    static let tooManyTransaction = NSLocalizedString(
        "You have too many pending %@ transactions. Once those complete you can create a new one.",
        comment: "You have too many pending %@ transactions. Once those complete you can create a new one."
    )

    static let orderNotCancellable = NSLocalizedString(
        "Oops! This %@ order is not cancellable.",
        comment: "Oops! This %@ order is not cancellable."
    )

    static let pendingWithdraw = NSLocalizedString(
        "Oops! You’ve already got an existing pending withdrawal, please try again once that completes.",
        comment: "Oops! You’ve already got an existing pending withdrawal, please try again once that completes."
    )

    static let withdrawBalanceLocked = NSLocalizedString(
        "Oops! For security reasons, your balance is currently locked, please try again later.",
        comment: "Oops! For security reasons, your balance is currently locked, please try again later."
    )

    static let tradingInsufficientFunds = NSLocalizedString(
        "Oops! You don’t have enough funds to Withdraw",
        comment: "Oops! You don’t have enough funds to Withdraw"
    )

    static let internalServiceError = NSLocalizedString(
        "Oops! This service is currently unavailable, please try again later.",
        comment: "Oops! This service is currently unavailable, please try again later."
    )

    static let tradingAlbertError = NSLocalizedString(
        "Oops! Something Went Wrong. Please try again.",
        comment: "Oops! Something Went Wrong. Please try again."
    )

    static let tradingServiceDisabled = NSLocalizedString(
        "This service will be back soon. We’re updating and fixing some bugs right now.",
        comment: "This service will be back soon. We’re updating and fixing some bugs right now."
    )

    static let tradingInsufficientBalance = NSLocalizedString(
        "Oops! You don’t have enough balance to %@.",
        comment: "Oops! You don’t have enough balance to %@."
    )

    static let tradingBelowMin = NSLocalizedString(
        "Oops! The amount you selected is below the minimum %@ limit.",
        comment: "Oops! The amount you selected is below the minimum %@ limit."
    )

    static let tradingAboveMax = NSLocalizedString(
        "Oops! The amount you selected is above the maximum %@ limit.",
        comment: "Oops! The amount you selected is above the maximum %@ limit."
    )

    static let tradingDailyExceeded = NSLocalizedString(
        "Oops! You’ve exceeded your daily %@ limit",
        comment: "Oops! You’ve exceeded your daily %@ limit"
    )

    static let tradingWeeklyExceeded = NSLocalizedString(
        "Oops! You’ve exceeded your weekly %@ limit",
        comment: "Oops! You’ve exceeded your weekly %@ limit"
    )

    static let tradingYearlyExceeded = NSLocalizedString(
        "Oops! You’ve exceeded your yearly %@ limit",
        comment: "Oops! You’ve exceeded your yearly %@ limit"
    )

    static let tradingInvalidAddress = NSLocalizedString(
        "Oops! Looks like that address is invalid, please try again.",
        comment: "Oops! Looks like that address is invalid, please try again."
    )

    static let tradingInvalidCurrency = NSLocalizedString(
        "Oops! Looks like that cryptocurrency is invalid, please try again.",
        comment: "Oops! Looks like that cryptocurrency is invalid, please try again."
    )

    static let tradingInvalidFiat = NSLocalizedString(
        "Oops! Looks like that fiat is invalid, please try again.",
        comment: "Oops! Looks like that fiat is invalid, please try again."
    )

    static let tradingDirectionDisabled = NSLocalizedString(
        "Oops! That service isn’t available at the moment, please try again later.",
        comment: "Oops! That service isn’t available at the moment, please try again later."
    )

    static let tradingQuoteInvalidOrExpired = NSLocalizedString(
        "Oops! The amount we quoted you is no longer valid, please try again.",
        comment: "Oops! The amount we quoted you is no longer valid, please try again."
    )

    static let executingTransactionError = NSLocalizedString(
        "Oops! Something went wrong while executing the %@ on-chain transaction.",
        comment: "Oops! Something went wrong while executing the %@ on-chain transaction."
    )

    static let tradingIneligibleForSwap = NSLocalizedString(
        "Oops! This service isn’t currently available. Please contact support.",
        comment: "Oops! This service isn’t currently available. Please contact support."
    )

    static let tradingInvalidDestinationAmount = NSLocalizedString(
        "Oops! Looks like that isn’t a valid amount, please try again.",
        comment: "Oops! Looks like that isn’t a valid amount, please try again."
    )
}

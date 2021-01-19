//
//  LocalizationConstants+Swap.swift
//  Localization
//
//  Created by Paulo on 08/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    
    public enum Swap {
        public enum Trending {
            public enum Header {
                public static let title = NSLocalizedString("Swap Your Crypto", comment: "Swap Your Crypto")
                public static let description = NSLocalizedString("Instantly exchange your crypto into any currency we offer for your wallet.", comment: "Instantly exchange your crypto into any currency we offer for your wallet.")
            }
            public static let trending = NSLocalizedString("Trending", comment: "Trending")
            public static let newSwap = NSLocalizedString("New Swap", comment: "New Swap")
        }
        public static let available = NSLocalizedString("Available", comment: "")
        public static let your = NSLocalizedString("Your", comment: "")
        public static let balance = NSLocalizedString("Balance", comment: "")
        public static let successfulExchangeDescription = NSLocalizedString("Success! Your Exchange has been started!", comment: "A successful swap alert")
        public static let viewOrderDetails = NSLocalizedString("View Order Details", comment: "View Order Details")
        public static let exchangeStarted = NSLocalizedString("Your Exchange has been started!", comment: "Your exchange has been started")
        public static let exchangeAirdropDescription = NSLocalizedString("Even better, since you need ETH to make USD Digital trades, we just airdropped enough ETH into your Wallet to cover your first 3 transactions 🙌🏻", comment: "ETH Airdrop description")
        public static let viewMySwapLimit = NSLocalizedString(
            "View My Swap Limit",
            comment: "Text displayed on the CTA when the user wishes to view their swap limits."
        )
        public static let helpDescription = NSLocalizedString(
            "Our Blockchain Support Team is standing by to help any questions you have.",
            comment: "Text displayed in the help modal."
        )
        public static let tier = NSLocalizedString(
            "Tier", comment: "Text shown to represent the level of access a user has to Swap features."
        )
        public static let locked = NSLocalizedString(
            "Locked", comment: "Text shown to indicate that Swap features have not been unlocked yet."
        )
        public static let swap = NSLocalizedString(
            "Swap", comment: "Text shown for the crypto exchange service."
        )
        public static let confirmSwap = NSLocalizedString(
            "Confirm Swap", comment: "Button text shown on the exchange confirm screen to execute the swap"
        )
        public static let swapLocked = NSLocalizedString(
            "Swap Locked", comment: "Button text shown on the exchange screen to show that a swap has been confirmed"
        )
        public static let tierlimitErrorMessage = NSLocalizedString(
            "Your max is %@.", comment: "Error message shown on the exchange screen when a user's exchange input would exceed their tier limit"
        )
        public static let upgradeNow = NSLocalizedString(
            "Upgrade now.", comment: "Call to action shown to encourage the user to reach a higher swap tier"
        )
        public static let postTierError = NSLocalizedString(
            "An error occurred when selecting your tier. Please try again later.", comment: "Error shown when a user selects a tier and an error occurs when posting the tier to the server"
        )
        public static let swapCardMessage = NSLocalizedString(
            "Exchange one crypto for another without ever leaving your Blockchain Wallet.",
            comment: "Message on the swap card"
        )
        public static let checkItOut = NSLocalizedString("Check it out!", comment: "CTA on the swap card")
        public static let swapInfo = NSLocalizedString("Swap Info", comment: "Swap Info")
        public static let close = NSLocalizedString("Close", comment: "Close")
        public static let orderHistory = NSLocalizedString("Order History", comment: "Order History")
        
        public struct Tutorial {
            public struct PageOne {
                public static let title = NSLocalizedString("Welcome to Swap!", comment: "")
                public static let subtitle = NSLocalizedString("The easiest way to exchange one crypto for another without leaving your wallet.", comment: "")
            }
            public struct PageTwo {
                public static let title = NSLocalizedString("Real-time Exchange Rates", comment: "")
                public static let subtitle = NSLocalizedString("Access competitive crypto prices right at your fingertips.", comment: "")
            }
            public struct PageThree {
                public static let title = NSLocalizedString("100% On-Chain", comment: "")
                public static let subtitle = NSLocalizedString("All Swap trades are confirmed and settled directly on-chain.", comment: "")
            }
            public struct PageFour {
                public static let title = NSLocalizedString("You Control Your Key", comment: "")
                public static let subtitle = NSLocalizedString("With Swap your crypto is safe, secure, and your keys are always intact.", comment: "")
            }
            public struct PageFive {
                public static let title = NSLocalizedString("Manage Risk Better", comment: "")
                public static let subtitle = NSLocalizedString("Introducing Digital US Dollars (USD Digital) to de-risk your crypto investment or lock-in gains.", comment: "")
            }
        }
        
        public static let navigationTitle = NSLocalizedString(
            "Exchange",
            comment: "Title text shown on navigation bar for exchanging a crypto asset for another"
        )
        public static let complete = NSLocalizedString(
            "Complete",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let delayed = NSLocalizedString(
            "Delayed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let expired = NSLocalizedString(
            "Expired",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let failed = NSLocalizedString(
            "Failed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let inProgress = NSLocalizedString(
            "In Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refundInProgress = NSLocalizedString(
            "Refund in Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refunded = NSLocalizedString(
            "Refunded",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let loading = NSLocalizedString(
            "Loading Exchange",
            comment: "Text presented when the wallet is loading the exchange"
        )
        public static let loadingTransactions = NSLocalizedString("Loading transactions", comment: "")
        public static let gettingQuote = NSLocalizedString("Getting quote", comment: "")
        public static let confirming = NSLocalizedString("Confirming", comment: "")
        public static let useMin = NSLocalizedString(
            "Use min",
            comment: "Text displayed on button for user to tap to create a trade with the minimum amount of crypto allowed"
        )
        public static let useMax = NSLocalizedString(
            "Use max",
            comment: "Text displayed on button for user to tap to create a trade with the maximum amount of crypto allowed"
        )
        public static let to = NSLocalizedString("To", comment: "Label for exchanging to a specific type of crypto")
        public static let from = NSLocalizedString("From", comment: "Label for exchanging from a specific type of crypto")
        public static let homebrewInformationText = NSLocalizedString(
            "All amounts are correct at this time but might change depending on the market price and transaction rates at the time your order is processed",
            comment: "Text displayed on exchange screen to inform user of changing market rates"
        )
        public static let orderID = NSLocalizedString("Order ID", comment: "Label in the exchange locked screen.")
        public static let exchangeLocked = NSLocalizedString("Exchange Locked", comment: "Header title for the Exchange Locked screen.")
        public static let done = NSLocalizedString("Done", comment: "Footer button title")
        public static let confirm = NSLocalizedString("Confirm", comment: "Footer button title for Exchange Confirmation screen")
        public static let creatingOrder = NSLocalizedString("Creating order", comment: "Loading text shown when a final exchange order is being created")
        public static let sendingOrder = NSLocalizedString("Sending order", comment: "Loading text shown when a final exchange order is being sent")
        public static let exchangeXForY = NSLocalizedString(
            "Exchange %@ for %@",
            comment: "Text displayed on the primary action button for the exchange screen when exchanging between 2 assets."
        )
        public static let receive = NSLocalizedString(
            "Receive",
            comment: "Text displayed when reviewing the amount to be received for an exchange order")
        public static let estimatedFees = NSLocalizedString(
            "Estimated fees",
            comment: "Text displayed when reviewing the estimated amount of fees to pay for an exchange order")
        public static let value = NSLocalizedString(
            "Value",
            comment: "Text displayed when reviewing the fiat value of an exchange order")
        public static let sendTo = NSLocalizedString(
            "Send to",
            comment: "Text displayed when reviewing where the result of an exchange order will be sent to")
        public static let expiredDescription = NSLocalizedString(
            "Your order has expired. No funds left your account.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        public static let delayedDescription = NSLocalizedString(
            "Your order has not completed yet due to network delays. It will be processed as soon as funds are received.",
            comment: "Helper text shown when a user is viewing an order that is delayed."
        )
        public static let tradeProblemWindow = NSLocalizedString(
            "Unfortunately, there is a problem with your order. We are researching and will resolve very soon.",
            comment: "Helper text shown when a user is viewing an order that is stuck (e.g. pending withdrawal and older than 24 hours)."
        )
        public static let failedDescription = NSLocalizedString(
            "There was a problem with your order.",
            comment: "Helper text shown when a user is viewing an order that has expired."
        )
        public static let whatDoYouWantToExchange = NSLocalizedString(
            "What do you want to exchange?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange from."
        )
        public static let whatDoYouWantToReceive = NSLocalizedString(
            "What do you want to receive?",
            comment: "Text displayed on the action sheet that is presented when the user is selecting an account to exchange into."
        )
        
        public static let fees = NSLocalizedString("Fees", comment: "Fees")
        public static let confirmExchange = NSLocalizedString(
            "Confirm Exchange",
            comment: "Confirm Exchange"
        )
        public static let amountVariation = NSLocalizedString(
            "The amounts you send and receive may change slightly due to market activity.",
            comment: "Disclaimer in exchange locked screen"
        )
        public static let orderStartDisclaimer = NSLocalizedString(
            "Once an order starts, we are unable to stop it.",
            comment: "Second disclaimer in exchange locked screen"
        )
        public static let status = NSLocalizedString(
            "Status",
            comment: "Status of a trade in the exchange overview screen"
        )
        public static let exchange = NSLocalizedString(
            "Exchange",
            comment: "Exchange"
        )
        public static let aboveTradingLimit = NSLocalizedString(
            "Above trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount above their designated limit"
        )
        public static let belowTradingLimit = NSLocalizedString(
            "Below trading limit",
            comment: "Error message shown when a user is attempting to exchange an amount below their designated limit"
        )
        public static let insufficientFunds = NSLocalizedString(
            "Insufficient funds",
            comment: "Error message shown when a user is attempting to exchange an amount greater than their balance"
        )
        
        public static let yourMin = NSLocalizedString(
            "Your Min is",
            comment: "Error that displays what the minimum amount of fiat is required for a trade"
        )
        public static let yourMax = NSLocalizedString(
            "Your Max is",
            comment: "Error that displays what the maximum amount of fiat allowed for a trade"
        )
        public static let notEnough = NSLocalizedString(
            "Not enough",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        public static let yourBalance = NSLocalizedString(
            "Your balance is",
            comment: "Part of error message shown when the user doesn't have enough funds to make an exchange"
        )
        public static let tradeExecutionError = NSLocalizedString(
            "Sorry, an order cannot be placed at this time.",
            comment: "Error message shown to a user if something went wrong during the exchange process and the user cannot continue"
        )
        public static let exchangeListError = NSLocalizedString(
            "Sorry, your orders cannot be fetched at this time.",
            comment: "Error message shown to a user if something went wrong while fetching the user's exchange orders"
        )
        public static let yourSpendableBalance = NSLocalizedString(
            "Your spendable balance is",
            comment: "Error message shown to a user if they try to exchange more than what is permitted."
        )
        public static let marketsMoving = NSLocalizedString(
            "Markets are Moving 🚀",
            comment: "Error title when markets are fluctuating on the order confirmation screen"
        )
        public static let holdHorses = NSLocalizedString(
            "Whoa! Hold your horses. 🐴",
            comment: "Error title shown when users are exceeding their limits in the order confirmation screen."
        )
        public static let marketMovementMinimum = NSLocalizedString(
            "Due to market movement, your order value is now below the minimum required threshold of",
            comment: "Error message shown to a user if they try to exchange too little."
        )
        public static let marketMovementMaximum = NSLocalizedString(
            "Due to market movement, your order value is now above the maximum allowable threshold of",
            comment: "Error message shown to a user if they try to exchange too much."
        )
        public static let dailyAnnualLimitExceeded = NSLocalizedString(
            "There is a limit to how much crypto you can exchange. The value of your order must be less than your limit of",
            comment: "Error message shown to a user if they try to exchange beyond their limits whether annual or daily."
        )
        public static let oopsSomethingWentWrong = NSLocalizedString(
            "Ooops! Something went wrong.",
            comment: "Oops error title"
        )
        public static let oopsSwapDescription = NSLocalizedString(
            "We're not sure what happened but we didn't receive your order details.  Unfortunately, you're going to have to enter your order again.",
            comment: "Message that coincides with the `Oops! Something went wrong.` error title."
        )
        public static let somethingNotRight = NSLocalizedString(
            "Hmm, something's not right. 👀",
            comment: "Error title shown when a trade's status is `stuck`."
        )
        public static let somethingNotRightDetails = NSLocalizedString(
            "Most exchanges on Swap are completed seamlessly in two hours.  Please contact us. Together, we can figure this out.",
            comment: "Error description that coincides with `something's not right`."
        )
        public static let networkDelay = NSLocalizedString("Network Delays", comment: "Network Delays")
        public static let dontWorry = NSLocalizedString(
            "Don't worry, your exchange is in process. Swap trades are competed on-chain. If transaction volumes are high, there are sometimes delays.",
            comment: "Network delay description."
        )
        public static let moreInfo = NSLocalizedString("More Info", comment: "More Info")
        public static let updateOrder = NSLocalizedString("Update Order", comment: "Update Order")
        public static let tryAgain = NSLocalizedString("Try Again", comment: "try again")
        public static let increaseMyLimits = NSLocalizedString("Increase My Limits", comment: "Increase My Limits")
        public static let learnMore = NSLocalizedString("Learn More", comment: "Learn More")
    }
}

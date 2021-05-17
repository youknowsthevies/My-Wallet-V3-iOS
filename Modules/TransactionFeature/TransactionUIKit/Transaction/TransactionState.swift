// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit
import TransactionKit

struct TransactionState: Equatable, StateType {

    var action: AssetAction = .send
    var allowFiatInput: Bool = false
    var availableSources: [BlockchainAccount] = []
    var availableTargets: [TransactionTarget] = []
    var destination: TransactionTarget?
    var destinationToFiatPair: MoneyValuePair?
    var errorState: TransactionErrorState = .none
    var executionStatus: TransactionExecutionStatus = .notStarted
    var isGoingBack: Bool = false
    var nextEnabled: Bool = false
    var passwordRequired: Bool = false
    var pendingTransaction: PendingTransaction?
    var secondPassword: String = ""
    var source: BlockchainAccount?
    var sourceDestinationPair: MoneyValuePair?
    var sourceToFiatPair: MoneyValuePair?
    var step: TransactionStep = .initial {
        didSet {
            isGoingBack = false
        }
    }
    var stepsBackStack: [TransactionStep] = []

    static func == (lhs: TransactionState, rhs: TransactionState) -> Bool {
        lhs.action == rhs.action
            && lhs.allowFiatInput == rhs.allowFiatInput
            && lhs.destination?.label == rhs.destination?.label
            && lhs.destinationToFiatPair == rhs.destinationToFiatPair
            && lhs.errorState == rhs.errorState
            && lhs.executionStatus == rhs.executionStatus
            && lhs.isGoingBack == rhs.isGoingBack
            && lhs.nextEnabled == rhs.nextEnabled
            && lhs.passwordRequired == rhs.passwordRequired
            && lhs.pendingTransaction == rhs.pendingTransaction
            && lhs.secondPassword == rhs.secondPassword
            && lhs.source?.id == rhs.source?.id
            && lhs.sourceDestinationPair == rhs.sourceDestinationPair
            && lhs.sourceToFiatPair == rhs.sourceToFiatPair
            && lhs.step == rhs.step
            && lhs.stepsBackStack == rhs.stepsBackStack
            && lhs.availableSources.map(\.id) == rhs.availableSources.map(\.id)
            && lhs.availableTargets.map(\.label) == rhs.availableTargets.map(\.label)
    }

    /// The source account `CryptoCurrency`.
    var asset: CurrencyType {
        guard let sourceAccount = source else {
            preconditionFailure("Source should have been set at this point.")
        }
        guard let account = sourceAccount as? SingleAccount else {
            preconditionFailure("Expected a `SingleAccount`: \(String(describing: source))")
        }
        return account.currencyType
    }

    /// The fees associated with the transaction
    var feeSelection: FeeSelection {
        guard let pendingTx = pendingTransaction else {
            /// If there is no `pendingTransaction` then the
            /// available fee levels is `[.none]`
            return .empty(asset: asset)
        }
        return pendingTx.feeSelection
    }

    /// The amount the user is swapping from.
    var amount: MoneyValue {
        pendingTransaction?.amount ?? .zero(currency: asset)
    }

    var minSpendable: MoneyValue {
        pendingTransaction?.minimumLimit ?? .zero(currency: asset)
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `maxLimit` as `CryptoValues` and return whichever is smaller.
    var maxSpendable: MoneyValue {
        pendingTransaction?.maxSpendable ?? .zero(currency: asset)
    }

    /// The balance in `MoneyValue` based on the `PendingTransaction`
    var availableBalance: MoneyValue {
        pendingTransaction?.available ?? .zero(currency: asset)
    }

    func moneyValueFromSource() -> Result<MoneyValue, TransactionUIKitError> {
        guard let rate = sourceToFiatPair else {
            return .success(.zero(currency: asset))
        }
        guard let currencyType = rate.base.cryptoValue?.currencyType else {
            return .failure(.unexpectedMoneyValueType(rate.base))
        }
        guard let quote = rate.quote.fiatValue else {
            return .failure(.unexpectedMoneyValueType(rate.quote))
        }
        switch (amount.cryptoValue, amount.fiatValue) {
        case (.some(let amount), .none):
            /// Just show the `CryptoValue` that the user entered
            /// as this is the `source` currency.
            return .success(.init(cryptoValue: amount))
        case (.none, .some(let amount)):
            /// Convert the `FiatValue` to a `CryptoValue` given the
            /// `quote` from the `sourceToFiatPair` exchange rate.
            return .success(amount
                .convertToCryptoValue(
                    exchangeRate: quote,
                    cryptoCurrency: currencyType
                )
                .moneyValue
            )
        default:
            break
        }
        return .success(.zero(currency: currencyType))
    }

    /// The `MoneyValue` representing the amount received
    /// or the amount that is sent to the given destination.
    func moneyValueFromDestination() -> Result<MoneyValue, TransactionUIKitError> {
        let currencyType: CurrencyType
        switch destination {
        case let account as SingleAccount:
            currencyType = account.currencyType
        case let receiveAddress as CryptoReceiveAddress:
            currencyType = receiveAddress.asset.currency
        default:
            return .failure(.unexpectedDestinationAccountType)
        }
        guard let exchange = sourceDestinationPair else {
            return .success(.zero(currency: currencyType))
        }
        guard case let .crypto(currency) = exchange.quote.currencyType else {
            return .failure(.unexpectedCurrencyType(exchange.quote.currencyType))
        }
        guard let sourceQuote = sourceToFiatPair?.quote.fiatValue else {
            return .failure(.emptySourceExchangeRate)
        }
        guard let destinationQuote = destinationToFiatPair?.quote.fiatValue else {
            return .failure(.emptyDestinationExchangeRate)
        }

        switch (amount.cryptoValue,
                amount.fiatValue,
                exchange.quote.cryptoValue) {
        case (.none, .some(let fiat), .some(let cryptoPrice)):
            /// Conver the `fiatValue` amount entered into
            /// a `CryptoValue`
            return .success(
                fiat.convertToCryptoValue(
                    exchangeRate: destinationQuote,
                    cryptoCurrency: cryptoPrice.currencyType
                )
                .moneyValue
            )
        case (.some(let crypto), .none, _):
            /// Convert the `cryptoValue` input into a `fiatValue` type.
            let fiat = crypto.convertToFiatValue(exchangeRate: sourceQuote)
            /// Convert the `fiatValue` input into a `cryptoValue` type
            /// given the `quote` of the `destinationCurrencyType`.
            return .success(
                fiat.convertToCryptoValue(
                    exchangeRate: destinationQuote,
                    cryptoCurrency: currency
                )
                .moneyValue
            )
        default:
            return .success(.zero(currency: currency))
        }
    }

    /// Converts an FiatValue `available` into CryptoValue if necessary.
    private func availableToAmountCurrency(available: MoneyValue, amount: MoneyValue) throws -> MoneyValue {
        guard amount.isFiat else {
            return available
        }
        guard let rate = sourceToFiatPair else {
            return .zero(currency: amount.currency)
        }
        return try available.convert(using: rate.quote)
    }
}

enum TransactionStep: Equatable {
    case initial
    case enterPassword
    case selectSource
    case enterAddress
    case selectTarget
    case enterAmount
    case confirmDetail
    case inProgress
    case closed

    var addToBackStack: Bool {
        switch self {
        case .selectSource,
             .selectTarget,
             .enterAddress,
             .enterAmount:
            return true
        case .closed,
             .confirmDetail,
             .enterPassword,
             .inProgress,
             .initial:
            return false
        }
    }
}

enum TransactionErrorState: Equatable {
    case none
    case addressIsContract
    case belowMinimumLimit
    case insufficientFunds
    case insufficientGas
    case insufficientFundsForFees
    case invalidAddress
    case invalidAmount
    case invalidPassword
    case optionInvalid
    case overGoldTierLimit
    case overMaximumLimit
    case overSilverTierLimit
    case pendingOrdersLimitReached
    case transactionInFlight
    case unknownError
}

enum TransactionExecutionStatus {
    case notStarted
    case inProgress
    case error
    case completed

    var isComplete: Bool {
        self == .completed
    }
}

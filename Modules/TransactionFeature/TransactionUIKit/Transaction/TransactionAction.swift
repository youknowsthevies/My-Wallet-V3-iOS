// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

enum TransactionAction: MviAction {

    case initialiseWithNoSourceOrTargetAccount(action: AssetAction, passwordRequired: Bool)
    case initialiseWithSourceAccount(action: AssetAction, sourceAccount: BlockchainAccount, passwordRequired: Bool)
    case initialiseWithSourceAndPreferredTarget(action: AssetAction,
                                                sourceAccount: BlockchainAccount,
                                                target: TransactionTarget,
                                                passwordRequired: Bool)
    case initialiseWithSourceAndTargetAccount(action: AssetAction,
                                              sourceAccount: BlockchainAccount,
                                              target: TransactionTarget,
                                              passwordRequired: Bool)
    case initialiseWithTargetAndNoSource(action: AssetAction, target: TransactionTarget, passwordRequired: Bool)
    case sourceAccountSelected(BlockchainAccount)
    case targetAccountSelected(TransactionTarget)
    case availableSourceAccountsListUpdated([BlockchainAccount])
    case availableDestinationAccountsListUpdated([BlockchainAccount])
    case updateAmount(MoneyValue) // Anytime the amount changes
    case pendingTransactionUpdated(PendingTransaction)
    case prepareTransaction // When continue button is tapped on enter amount screen
    case executeTransaction
    case updateTransactionComplete(TransactionResult)
    case fetchFiatRates
    case fetchTargetRates
    case updateFeeLevelAndAmount(FeeLevel, MoneyValue?)
    case sourceDestinationPair(MoneyValuePair)
    case transactionFiatRatePairs(TransactionMoneyValuePairs)
    case fatalTransactionError(Error)
    case validateTransaction
    case resetFlow
    case returnToPreviousStep
    case pendingTransactionStarted(allowFiatInput: Bool)
    case modifyTransactionConfirmation(TransactionConfirmation)
    case invalidateTransaction

    func reduce(oldState: TransactionState) -> TransactionState {
        switch self {
        case .pendingTransactionStarted(let allowFiatInput):
            var newState = oldState
            newState.errorState = .none
            newState.allowFiatInput = allowFiatInput
            newState.nextEnabled = false
            return newState.withUpdatedBackstack(oldState: oldState)
        case .updateFeeLevelAndAmount:
            return oldState
        case let .initialiseWithSourceAndTargetAccount(action, sourceAccount, target, passwordRequired):
            /// If the user scans a BitPay QR code, the account will be a
            /// BitPayInvoiceTarget. This means we do not proceed to the enter amount
            /// screen but rather the confirmation detail screen.
            let next: TransactionStep = target is BitPayInvoiceTarget ? .confirmDetail : .enterAmount
            let step = passwordRequired ? .enterPassword : next
            return TransactionState(
                action: action,
                destination: target,
                errorState: .none,
                passwordRequired: passwordRequired,
                source: sourceAccount,
                step: step
            ).withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithSourceAndPreferredTarget(action, sourceAccount, target, passwordRequired):
            return TransactionState(
                action: action,
                destination: target,
                errorState: .none,
                passwordRequired: passwordRequired,
                source: sourceAccount,
                step: .enterAmount
            ).withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithTargetAndNoSource(action, target, passwordRequired):
            return TransactionState(
                action: action,
                destination: target,
                errorState: .none,
                passwordRequired: passwordRequired,
                source: nil,
                step: .selectSource
            ).withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithNoSourceOrTargetAccount(action, passwordRequired):
            return TransactionState(
                action: action,
                errorState: .none,
                passwordRequired: passwordRequired,
                step: .selectSource
            ).withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithSourceAccount(action, sourceAccount, passwordRequired):
            return TransactionState(
                action: action,
                errorState: .none,
                passwordRequired: passwordRequired,
                source: sourceAccount
            )
        case .fetchFiatRates:
            return oldState
        case .fetchTargetRates:
            return oldState
        case .sourceDestinationPair(let pair):
            var newState = oldState
            newState.sourceDestinationPair = pair
            return newState
        case .transactionFiatRatePairs(let pair):
            var newState = oldState
            newState.destinationToFiatPair = pair.destination
            newState.sourceToFiatPair = pair.source
            return newState
        case .sourceAccountSelected(let sourceAccount):
            var newState = oldState
            newState.source = sourceAccount
            newState.sourceDestinationPair = nil
            newState.sourceToFiatPair = nil
            newState.destinationToFiatPair = nil
            return newState
        case .targetAccountSelected(let destinationAccount):
            /// If the user scans a BitPay QR code, the account will be a
            /// BitPayInvoiceTarget. This means we do not proceed to the enter amount
            /// screen but rather the confirmation detail screen.
            let step: TransactionStep = destinationAccount is BitPayInvoiceTarget ? .confirmDetail : .enterAmount
            var newState = oldState
            newState.errorState = .none
            newState.destination = destinationAccount
            newState.nextEnabled = false
            newState.step = step
            newState.sourceDestinationPair = nil
            newState.sourceToFiatPair = nil
            newState.destinationToFiatPair = nil
            return newState.withUpdatedBackstack(oldState: oldState)
        case .updateAmount:
            // Amount is updated after validation.
            var newState = oldState
            newState.nextEnabled = false
            return newState
        case .availableSourceAccountsListUpdated(let sources):
            var newState = oldState
            newState.availableSources = sources
            return newState.withUpdatedBackstack(oldState: oldState)
        case .availableDestinationAccountsListUpdated(let targets):
            let newStep: TransactionStep = oldState.passwordRequired ? .enterPassword : .selectTarget
            var newState = oldState
            newState.availableTargets = targets as! [TransactionTarget]
            newState.step = oldState.step == .enterAmount ? .enterAmount : newStep
            return newState.withUpdatedBackstack(oldState: oldState)
        case .pendingTransactionUpdated(let pendingTransaction):
            var newState = oldState
            newState.pendingTransaction = pendingTransaction
            newState.nextEnabled = pendingTransaction.validationState == .canExecute
            newState.errorState = pendingTransaction.validationState.mapToTransactionErrorState
            return newState.withUpdatedBackstack(oldState: oldState)
        case .prepareTransaction:
            var newState = oldState
            newState.nextEnabled = false // Don't enable until we get a validated pendingTx from the interactor
            newState.step = .confirmDetail
            return newState.withUpdatedBackstack(oldState: oldState)
        case .executeTransaction:
            var newState = oldState
            newState.nextEnabled = false
            newState.step = .inProgress
            newState.executionStatus = .inProgress
            return newState.withUpdatedBackstack(oldState: oldState)
        case .updateTransactionComplete:
            var newState = oldState
            newState.nextEnabled = true
            newState.executionStatus = .completed
            return newState.withUpdatedBackstack(oldState: oldState)
        case .fatalTransactionError(let error):
            Logger.shared.error(String(describing: error))
            var newState = oldState
            newState.nextEnabled = true
            newState.step = .inProgress
            newState.errorState = .fatalError(FatalTransactionError(error: error))
            newState.executionStatus = .error
            return newState.withUpdatedBackstack(oldState: oldState)
        case .validateTransaction:
            return oldState
        case .resetFlow:
            var newState = oldState
            newState.step = .closed
            return newState
        case .returnToPreviousStep:
            var stepsBackStack = oldState.stepsBackStack
            let previousStep = stepsBackStack.popLast() ?? .initial
            return oldState
                .update(keyPath: \.stepsBackStack, value: stepsBackStack)
                .update(keyPath: \.step, value: previousStep)
                .update(keyPath: \.isGoingBack, value: true)
                .update(keyPath: \.errorState, value: .none)
        case .modifyTransactionConfirmation:
            return oldState
        case .invalidateTransaction:
            return oldState
                .update(keyPath: \.pendingTransaction, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
                .withUpdatedBackstack(oldState: oldState)
        }
    }

    func isValid(for oldState: TransactionState) -> Bool {
        switch self {
        default:
            return true
        }
    }
}

enum FatalTransactionError: Error, Equatable {
    case rxError(RxError)
    case generic(Error)

    /// Initializes the enum with the given error, this check if it's an RxError and assigns correctly
    /// - Parameter error: An `Error` to be assigned
    init(error: Error) {
        guard let error = error as? RxError else {
            self = .generic(error)
            return
        }
        self = .rxError(error)
    }

    var rxError: RxError? {
        switch self {
        case .rxError(let error):
            return error
        case .generic:
            return nil
        }
    }

    var localizedDescription: String? {
        switch self {
        case .rxError(let error):
            return "\(LocalizationConstants.Errors.genericError) \n\(error.debugDescription)"
        case .generic(let error):
            return String(describing: error)
        }
    }

    static func == (lhs: FatalTransactionError, rhs: FatalTransactionError) -> Bool {
        switch (lhs, rhs) {
        case (.rxError(let left), .rxError(let right)):
            return left.debugDescription == right.localizedDescription
        case (.generic(let left), .generic(let right)):
            return left.localizedDescription == right.localizedDescription
        default:
            return false
        }
    }
}

extension TransactionState {
    func withUpdatedBackstack(oldState: TransactionState) -> TransactionState {
        if oldState.step != step, oldState.step.addToBackStack {
            var newState = self
            var newStack = oldState.stepsBackStack
            newStack.append(oldState.step)
            newState.stepsBackStack = newStack
            return newState
        }
        return self
    }
}

extension TransactionValidationState {
    var mapToTransactionErrorState: TransactionErrorState {
        switch self {
        case .addressIsContract:
            return .addressIsContract
        case .belowMinimumLimit:
            return .belowMinimumLimit
        case .canExecute:
            return .none
        case .insufficientFundsForFees:
            return .insufficientFundsForFees
        case .insufficientFunds:
            return .insufficientFunds
        case .insufficientGas:
            return .insufficientGas
        case .invalidAddress:
            return .invalidAddress
        case .invalidAmount:
            return .invalidAmount
        case .invoiceExpired:
            return .unknownError
        case .optionInvalid:
            return .optionInvalid
        case .overMaximumLimit:
            return .overMaximumLimit
        case .transactionInFlight:
            return .transactionInFlight
        case .uninitialized:
            return .none
        case .unknownError:
            return .unknownError
        case .overGoldTierLimit:
            return .overGoldTierLimit
        case .overSilverTierLimit:
            return .overSilverTierLimit
        case .pendingOrdersLimitReached:
            return .pendingOrdersLimitReached
        case .nabuError(let error):
            return .nabuError(error)
        }
    }
}

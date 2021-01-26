//
//  TransactionAction.swift
//  TransactionUIKit
//
//  Created by Paulo on 19/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit
import TransactionKit

enum TransactionAction: MviAction {

    case initialiseWithNoSourceOrTargetAccount(action: AssetAction, passwordRequired: Bool)
    case initialiseWithSourceAccount(action: AssetAction, sourceAccount: CryptoAccount, passwordRequired: Bool)
    case initialiseWithSourceAndPreferredTarget(action: AssetAction, sourceAccount: CryptoAccount, target: TransactionTarget, passwordRequired: Bool)
    case initialiseWithSourceAndTargetAccount(action: AssetAction, sourceAccount: CryptoAccount, target: TransactionTarget, passwordRequired: Bool)
    case sourceAccountSelected(CryptoAccount)
    case targetAccountSelected(TransactionTarget)
    case availableSourceAccountsListUpdated([CryptoAccount])
    case availableDestinationAccountsListUpdated([SingleAccount])
    case updateAmount(MoneyValue) // Anytime the amount changes
    case pendingTransactionUpdated(PendingTransaction)
    case prepareTransaction // When continue button is tapped on enter amount screen
    case executeTransaction
    case updateTransactionComplete(TransactionResult)
    case fetchFiatRates
    case fetchTargetRates
    case sourceDestinationPair(MoneyValuePair)
    case transactionFiatRatePairs(TransactionMoneyValuePairs)
    case fatalTransactionError(Error)
    case validateTransaction
    case resetFlow
    case returnToPreviousStep
    case pendingTransactionStarted(allowFiatInput: Bool)

    func reduce(oldState: TransactionState) -> TransactionState {
        switch self {
        case .pendingTransactionStarted(let allowFiatInput):
            var newState = oldState
            newState.errorState = .none
            newState.allowFiatInput = allowFiatInput
            newState.nextEnabled = false
            return newState.withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithSourceAndTargetAccount(action, sourceAccount, target, passwordRequired):
            let step: TransactionStep = passwordRequired ? .enterPassword : .enterAmount
            // TODO: BitPay: step = target is InvoiceTarget -> TransactionStep.CONFIRM_DETAIL
            return TransactionState(
                action: action,
                destination: target,
                errorState: .none,
                nextEnabled: passwordRequired,
                passwordRequired: passwordRequired,
                source: sourceAccount,
                step: step
            ).withUpdatedBackstack(oldState: oldState)
        case let .initialiseWithSourceAndPreferredTarget(action, sourceAccount, target, passwordRequired):
            // TICKET: [IOS-3825]
            // TODO: Initial step should be .enterAddress when that screen is implemented.
            return TransactionState(
                action: action,
                destination: target,
                errorState: .none,
                nextEnabled: true,
                passwordRequired: passwordRequired,
                source: sourceAccount,
                step: .enterAmount
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
                nextEnabled: passwordRequired,
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
            var newState = oldState
            newState.errorState = .none
            newState.destination = destinationAccount
            newState.nextEnabled = false
            newState.step = .enterAmount
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
            // TICKET: [IOS-3825]
            // TODO: Step should be .enterAddress when that screen is implemented.
            let newStep: TransactionStep = oldState.passwordRequired ? .enterPassword : .selectTarget
            var newState = oldState
            newState.availableTargets = targets
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
        case .updateTransactionComplete(let result):
            var newState = oldState
            newState.nextEnabled = true
            newState.executionStatus = .completed
            return newState.withUpdatedBackstack(oldState: oldState)
        case .fatalTransactionError(let error):
            Logger.shared.error(error.localizedDescription)
            var newState = oldState
            newState.nextEnabled = true
            newState.step = .inProgress
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
            var newState = oldState
            newState.stepsBackStack = stepsBackStack
            newState.step = previousStep
            newState.isGoingBack = true
            newState.errorState = .none
            return newState
        }
    }

    func isValid(for oldState: TransactionState) -> Bool {
        switch self {
        default:
            return true
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
        }
    }
}

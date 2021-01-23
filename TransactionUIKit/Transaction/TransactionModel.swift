//
//  TransactionModel.swift
//  TransactionUIKit
//
//  Created by Paulo on 13/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit
import TransactionKit

final class TransactionModel {
    
    // MARK: - Private Properties

    private var mviModel: MviModel<TransactionState, TransactionAction>!
    private let interactor: TransactionInteractor
    private var hasInitializedTransaction: Bool = false
    
    // MARK: - Public Properties

    var state: Observable<TransactionState> {
        mviModel.state
    }
    
    // MARK: - Init

    init(initialState: TransactionState = TransactionState(), transactionInteractor: TransactionInteractor) {
        self.interactor = transactionInteractor
        mviModel = MviModel(
            initialState: initialState,
            performAction: { [unowned self] (state, action) -> Disposable? in
                self.perform(previousState: state, action: action)
            }
        )
    }
    
    // MARK: - Internal methods
    
    func process(action: TransactionAction) {
        mviModel.process(action: action)
    }

    func perform(previousState: TransactionState, action: TransactionAction) -> Disposable? {
        switch action {
        case .pendingTransactionStarted:
            return nil
        case let .initialiseWithSourceAndTargetAccount(action, sourceAccount, target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: .zero(currency: sourceAccount.currencyType),
                action: action
            )
        case let .initialiseWithSourceAndPreferredTarget(action, sourceAccount, target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: .zero(currency: sourceAccount.currencyType),
                action: action
            )
        case let .initialiseWithNoSourceOrTargetAccount(action, _):
            return processSourceAccountsListUpdate(action: action)
        case .availableSourceAccountsListUpdated:
            return nil
        case .availableDestinationAccountsListUpdated:
            return nil
        case let .initialiseWithSourceAccount(action, sourceAccount, _):
            return processAccountsListUpdate(fromAccount: sourceAccount, action: action)
        case .targetAccountSelected(let destinationAccount):
            return processTargetSelectionConfirmed(
                sourceAccount: previousState.source!,
                transactionTarget: destinationAccount,
                amount: previousState.amount,
                action: previousState.action
            )
        case .updateAmount(let amount):
            return processAmountChanged(amount: amount)
        case .pendingTransactionUpdated:
            return nil
        case .prepareTransaction:
            return nil
        case .executeTransaction:
           return processExecuteTransaction(secondPassword: previousState.secondPassword)
        case .updateTransactionComplete:
            return nil
        case .fetchFiatRates:
            return processFiatRatePairs()
        case .fetchTargetRates:
            return processTransactionRatePair()
        case .transactionFiatRatePairs:
            return nil
        case .sourceDestinationPair:
            return nil
        case .fatalTransactionError:
            return nil
        case .validateTransaction:
            return processValidateTransaction()
        case .resetFlow:
            interactor.reset()
            return nil
        case .returnToPreviousStep:
            return nil
        case .sourceAccountSelected(let sourceAccount):
            return processAccountsListUpdate(fromAccount: sourceAccount, action: previousState.action)
        }
    }
    
    func destroy() {
        mviModel.destroy()
    }
    
    // MARK: - Private methods

    private func processSourceAccountsListUpdate(action: AssetAction) -> Disposable {
        interactor.getAvailableSourceAccounts(action: action)
            .subscribe(
                onSuccess: { [weak self] sourceAccounts in
                     self?.process(action: .availableSourceAccountsListUpdated(sourceAccounts))
                }
            )
    }

    private func processValidateTransaction() -> Disposable {
        interactor.validateTransaction
            .subscribe(onCompleted: {
                Logger.shared.debug("!TRANSACTION!> Tx validation complete")
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to processValidateTransaction: \(error.localizedDescription)")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processExecuteTransaction(secondPassword: String) -> Disposable {
        interactor.verifyAndExecute(secondPassword: secondPassword)
            .subscribe(onSuccess: { [weak self] result in
                self?.process(action: .updateTransactionComplete(result))
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to processExecuteTransaction: \(error.localizedDescription)")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processAmountChanged(amount: MoneyValue) -> Disposable? {
        guard hasInitializedTransaction else {
            return nil
        }
        return interactor.update(amount: amount)
            .subscribe(onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to process amount: \(error)")
                self?.process(action: .fatalTransactionError(error))
            })
    }
    
    // At this point we can build a transactor object from coincore and configure
    // the state object a bit more; depending on whether it's an internal, external,
    // bitpay or BTC Url address we can set things like note, amount, fee schedule
    // and hook up the correct processor to execute the transaction.
    private func processTargetSelectionConfirmed(sourceAccount: SingleAccount,
                                                 transactionTarget: TransactionTarget,
                                                 amount: MoneyValue,
                                                 action: AssetAction) -> Disposable {
        hasInitializedTransaction = false
        return interactor
            .initializeTransaction(sourceAccount: sourceAccount, transactionTarget: transactionTarget, action: action)
            .do(onNext: { [weak self] value in
                guard let self = self else { return }
                guard !self.hasInitializedTransaction else { return }
                self.hasInitializedTransaction.toggle()
                self.onFirstUpdate(amount: amount)
            })
            .subscribe(
                onNext: { [weak self] transaction in
                    self?.process(action: .pendingTransactionUpdated(transaction))
                },
                onError: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to process target selection: \(error.localizedDescription)")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }
    
    private func onFirstUpdate(amount: MoneyValue) {
        process(action: .pendingTransactionStarted(allowFiatInput: interactor.canTransactFiat))
        process(action: .fetchFiatRates)
        process(action: .fetchTargetRates)
        process(action: .updateAmount(amount))
    }

    private func processAccountsListUpdate(fromAccount: CryptoAccount, action: AssetAction) -> Disposable {
        interactor
            .getTargetAccounts(sourceAccount: fromAccount, action: action)
            .subscribe { [weak self] accounts in
                self?.process(action: .availableDestinationAccountsListUpdated(accounts))
            }
    }
    
    private func processFiatRatePairs() -> Disposable {
        interactor
            .startFiatRatePairsFetch
            .subscribe { [weak self] (transactionMoneyValuePairs) in
                self?.process(action: .transactionFiatRatePairs(transactionMoneyValuePairs))
            }
    }
    
    private func processTransactionRatePair() -> Disposable {
        interactor
            .startCryptoRatePairFetch
            .subscribe { [weak self] (moneyValuePair) in
                self?.process(action: .sourceDestinationPair(moneyValuePair))
            }
    }
}

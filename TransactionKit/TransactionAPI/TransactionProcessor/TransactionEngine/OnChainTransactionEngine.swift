//
//  OnChainTransactionEngine.swift
//  TransactionKit
//
//  Created by Paulo on 27/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol OnChainTransactionEngine: TransactionEngine {}

extension OnChainTransactionEngine {
    
    public func assertInputsValid() {
        guard let target = transactionTarget as? CryptoReceiveAddress else {
            preconditionFailure("\(String(describing: transactionTarget)) is not CryptoReceiveAddress")
        }
        precondition(!target.address.isEmpty)
        precondition(sourceAccount.asset == target.asset)
    }
    
    public func doPostExecute(transactionResult: TransactionResult) -> Completable {
        transactionTarget.onTxCompleted(transactionResult)
    }
    
    public func updateFeeSelection(cryptoCurrency: CryptoCurrency,
                                   pendingTransaction: PendingTransaction,
                                   newConfirmation: TransactionConfirmation.Model.FeeSelection) -> Single<PendingTransaction> {
        var pendingTransaction = pendingTransaction
        pendingTransaction.feeLevel = newConfirmation.selectedLevel
        pendingTransaction.customFeeAmount = newConfirmation.customFeeAmount
        return update(amount: pendingTransaction.amount, pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.validateAmount(pendingTransaction: pendingTransaction)
            }
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.doBuildConfirmations(pendingTransaction: pendingTransaction)
            }
    }
    
    public func getFeeState(pendingTransaction: PendingTransaction, feeOptions: FeeOptions? = nil) throws -> FeeState {
        switch (pendingTransaction.feeLevel, pendingTransaction.customFeeAmount) {
        case (.custom, nil):
            return .validCustomFee
        case (.custom, .some(let customFeeAmount)):
            let currency = pendingTransaction.amount.currency
            let zero: MoneyValue = .zero(currency: currency)
            guard let minimum = MoneyValue.create(minor: "1", currency: pendingTransaction.amount.currency) else {
                throw TransactionValidationFailure(state: .unknownError)
            }
            if try customFeeAmount < minimum {
                return .feeUnderMinLimit
            }
            if try customFeeAmount >= minimum, try customFeeAmount <= (feeOptions?.minLimit ?? zero) {
                return .feeUnderRecommended
            }
            if try customFeeAmount >= (feeOptions?.maxLimit ?? zero) {
                return .feeOverRecommended
            }
            return .validCustomFee
        default:
            if try pendingTransaction.available < pendingTransaction.amount {
                return .feeTooHigh
            }
            return .valid(absoluteFee: pendingTransaction.fees)
        }
    }
}

// TODO: Revisit
public struct FeeOptions {
    var minLimit: MoneyValue
    var maxLimit: MoneyValue
}

//
//  StellarTradeLimitsService.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxSwift
import StellarKit

class StellarTradeLimitsService: StellarTradeLimitsAPI {

    private let ledgerService: StellarLedgerAPI
    private let accountsService: StellarAccountAPI

    init(ledgerService: StellarLedgerAPI, accountsService: StellarAccountAPI) {
        self.ledgerService = ledgerService
        self.accountsService = accountsService
    }
    
    func validateCryptoAmount(amount: CryptoMoney) -> Single<TransactionValidationResult> {
        accountsService.currentStellarAccount(fromCache: true).flatMap(weak: self, { (self, account) -> Single<TransactionValidationResult> in
            self.maxSpendableAmount(for: account.identifier).map {
                let spendable = amount.amount <= $0.amount && amount.amount > 0
                return spendable ? .ok : .invalid(StellarFundsError.insufficientFunds)
            }
        })
    }

    func maxSpendableAmount(for accountId: AccountID) -> Single<CryptoValue> {
        let ledgerObservable = ledgerService.current.take(1)
        let accountDetailsObservable = accountsService.accountDetails(for: accountId).asObservable()
        let minRequiredObservable = minRequiredRemainingAmount(for: accountId).asObservable()

        return Observable.combineLatest(ledgerObservable, accountDetailsObservable, minRequiredObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .take(1)
            .asSingle()
            .map { ledger, accountDetails, minRequired -> CryptoValue in
                let balanceInXlm = accountDetails.assetAccount.balance
                let fees = ledger.baseFeeInXlm ?? CryptoValue.stellarZero
                let maxSpendable = (try? balanceInXlm - fees - minRequired) ?? CryptoValue.stellarZero
                return maxSpendable.amount > CryptoValue.stellarZero.amount ? maxSpendable : CryptoValue.stellarZero
            }
    }

    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<CryptoValue> {
        let ledgerObservable = ledgerService.current.take(1)
        let accountResponseObservable = accountsService.accountResponse(for: accountId).asObservable()
        return Observable.combineLatest(ledgerObservable, accountResponseObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .take(1)
            .asSingle()
            .map { ledger, accountResponse -> CryptoValue in
                let multiplier = BigInt(UInt(UInt(2) + accountResponse.subentryCount))
                let value: BigInt = multiplier * (ledger.baseReserveInXlm ?? CryptoValue.stellarZero).amount
                return CryptoValue.create(minor: value, currency: .stellar)
            }
    }

    func isSpendable(amount: CryptoValue, for accountId: AccountID) -> Single<Bool> {
        maxSpendableAmount(for: accountId)
            .map { maxSpendableAmount -> Bool in
                amount.amount <= maxSpendableAmount.amount && amount.amount > 0
            }
    }
}

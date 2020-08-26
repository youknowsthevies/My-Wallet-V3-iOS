//
//  StellarTradeLimitsMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import PlatformKit
import RxSwift

class StellarTradeLimitsMock: StellarTradeLimitsAPI {
    typealias AccountID = String

    func maxSpendableAmount(for accountId: AccountID) -> Single<CryptoValue> {
        Single.just(CryptoValue.stellarZero)
    }

    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<CryptoValue> {
        Single.just(CryptoValue.stellarZero)
    }

    func isSpendable(amount: CryptoValue, for accountId: AccountID) -> Single<Bool> {
        Single.just(true)
    }

    func validateCryptoAmount(amount: Crypto) -> Single<TransactionValidationResult> {
        Single.just(.ok)
    }
}

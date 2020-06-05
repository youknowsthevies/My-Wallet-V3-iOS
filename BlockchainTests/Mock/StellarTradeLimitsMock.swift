//
//  StellarTradeLimitsMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
@testable import Blockchain

class StellarTradeLimitsMock: StellarTradeLimitsAPI {
    typealias AccountID = String

    func maxSpendableAmount(for accountId: AccountID) -> Single<CryptoValue> {
        return Single.just(CryptoValue.lumensZero)
    }

    func minRequiredRemainingAmount(for accountId: AccountID) -> Single<CryptoValue> {
        return Single.just(CryptoValue.lumensZero)
    }

    func isSpendable(amount: CryptoValue, for accountId: AccountID) -> Single<Bool> {
        return Single.just(true)
    }

    func validateCryptoAmount(amount: Crypto) -> Single<TransactionValidationResult> {
        return Single.just(.ok)
    }
}

//
//  StellarMocks.swift
//  Blockchain
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import stellarsdk
import RxSwift
import RxRelay
import StellarKit
import PlatformKit
@testable import Blockchain

class StellarAccountMock: StellarAccountAPI {
    typealias AccountID = String
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountDetailsCompletion = ((Result<StellarAccount, Error>) -> Void)
    
    public var balanceType: BalanceType {
        return .nonCustodial
    }

    var currentAccount: StellarAccount?

    var balance: Single<CryptoValue> {
        return Single.error(NSError())
    }
    var balanceObservable: Observable<CryptoValue> {
        return Observable.error(NSError())
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    func currentStellarAccountAsSingle(fromCache: Bool) -> Single<StellarAccount?> {
        return .just(nil)
    }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        return Maybe.empty()
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        return Single.error(NSError())
    }

    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        return Maybe.empty()
    }

    func clear() {

    }

    func fundAccount(_ accountID: AccountID, amount: Decimal, sourceKeyPair: StellarKeyPair) -> Completable {
        return Completable.empty()
    }

    func prefetch() {

    }

    func validate(accountID: AccountID) -> Single<Bool> {
        return Single.just(false)
    }
    
    func isExchangeAddress(_ address: AccountID) -> Single<Bool> {
        return Single.just(false)
    }
}

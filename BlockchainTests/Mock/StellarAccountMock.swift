//
//  StellarMocks.swift
//  Blockchain
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import Foundation
import PlatformKit
import RxRelay
import RxSwift
import StellarKit
import stellarsdk

class StellarAccountMock: StellarAccountAPI {
    
    typealias AccountID = String
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountDetailsCompletion = ((Result<StellarAccount, Error>) -> Void)
    
    public var accountType: SingleAccountType {
        .nonCustodial
    }

    var currentAccount: StellarAccount?

    var balance: Single<CryptoValue> {
        Single.error(NSError())
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .stellar))
    }
    
    var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        Observable.error(NSError())
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    func currentStellarAccountAsSingle(fromCache: Bool) -> Single<StellarAccount?> {
        .just(nil)
    }
    
    func currentStellarAccount(fromCache: Bool) -> Maybe<StellarAccount> {
        Maybe.empty()
    }

    func accountResponse(for accountID: AccountID) -> Single<AccountResponse> {
        Single.error(NSError())
    }

    func accountDetails(for accountID: AccountID) -> Maybe<StellarAccount> {
        Maybe.empty()
    }

    func clear() {

    }

    func fundAccount(_ accountID: AccountID, amount: Decimal, sourceKeyPair: StellarKeyPair) -> Completable {
        Completable.empty()
    }

    func prefetch() {

    }

    func validate(accountID: AccountID) -> Single<Bool> {
        Single.just(false)
    }
    
    func isExchangeAddress(_ address: AccountID) -> Single<Bool> {
        Single.just(false)
    }
}

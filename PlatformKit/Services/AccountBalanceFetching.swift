//
//  AccountBalanceFetching.swift
//  PlatformKit
//
//  Created by Daniel Huri on 12/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

// MARK: - Base Protocol

/// This protocol defines a single responsibility requirement for an account balance fetching
public protocol AccountBalanceFetching: AnyObject {
    var balanceType: BalanceType { get }
    var balanceMoney: Single<MoneyValue> { get }
    var balanceMoneyObservable: Observable<MoneyValue> { get }
    var balanceFetchTriggerRelay: PublishRelay<Void> { get }
}

// MARK: - Crypto Protocol

public protocol CryptoAccountBalanceFetching: AccountBalanceFetching {
    var balance: Single<CryptoValue> { get }
}

extension CryptoAccountBalanceFetching {
    public var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
}

// MARK: - Fiat Protocol

public protocol FiatAccountBalanceFetching: AccountBalanceFetching {
    var balance: Single<FiatValue> { get }
}

extension FiatAccountBalanceFetching {
    public var balanceMoney: Single<MoneyValue> {
        balance.moneyValue
    }
}

public protocol CustodialAccountBalanceFetching: AccountBalanceFetching {
    /// Indicates, based on the data provided by the API, if the user has funded this account in the past.
    var isFunded: Observable<Bool> { get }
    
    /// Returns the funds state
    var fundsState: Observable<AccountBalanceState<MoneyValue>> { get }
}

/// AccountBalanceFetching implementation representing a absent account.
public final class AbsentAccountBalanceFetching: CustodialAccountBalanceFetching {
    
    public let balanceType: BalanceType

    public var balanceMoney: Single<MoneyValue> {
        balanceMoneyObservable.take(1).asSingle()
    }
    
    public var isFunded: Observable<Bool> {
        .just(false)
    }
    
    public var fundsState: Observable<AccountBalanceState<MoneyValue>> {
        .just(.absent)
    }

    public var balanceMoneyObservable: Observable<MoneyValue> {
        balanceRelay.asObservable()
    }

    public let balanceFetchTriggerRelay: PublishRelay<Void> = .init()
    private let balanceRelay: BehaviorRelay<MoneyValue>

    public init(currencyType: CurrencyType, balanceType: BalanceType) {
        balanceRelay = BehaviorRelay(value: .zero(currencyType))
        self.balanceType = balanceType
    }
}

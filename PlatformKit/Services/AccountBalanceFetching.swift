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

/// This protocol defines a single responsibility requirement for an account balance fetching
public protocol AccountBalanceFetching: class {
    var balanceType: BalanceType { get }
    var balance: Single<CryptoValue> { get }
    var balanceObservable: Observable<CryptoValue> { get }
    var balanceFetchTriggerRelay: PublishRelay<Void> { get }
}

public protocol CustodialAccountBalanceFetching: AccountBalanceFetching {
    /// Indicates, based on the data provided by the API, if the user has funded this account in the past.
    var isFunded: Observable<Bool> { get }
}

/// AccountBalanceFetching implementation representing a absent account.
public final class AbsentAccountBalanceFetching: AccountBalanceFetching {
    public let balanceType: BalanceType = .nonCustodial

    public var balance: Single<CryptoValue> {
        balanceObservable.take(1).asSingle()
    }

    public var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }

    public let balanceFetchTriggerRelay: PublishRelay<Void> = .init()
    private let balanceRelay: BehaviorRelay<CryptoValue>

    public init(cryptoCurrency: CryptoCurrency) {
        balanceRelay = BehaviorRelay(value: CryptoValue.zero(assetType: cryptoCurrency))
    }
}

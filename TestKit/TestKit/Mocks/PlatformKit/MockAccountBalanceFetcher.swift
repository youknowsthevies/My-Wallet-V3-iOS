// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

import PlatformKit

public final class MockAccountBalanceFetcher: SingleAccountBalanceFetching {

    public var pendingBalanceMoney: Single<MoneyValue> {
        .just(MoneyValue.zero(currency: expectedBalance.currency))
    }

    public var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }

    public var accountType: SingleAccountType {
        .nonCustodial
    }

    // MARK: - PropertiesEthereumKitTests Group

    public var balanceMoney: Single<MoneyValue> {
        Single.just(expectedBalance)
    }

    public var balanceMoneyObservable: Observable<MoneyValue> {
        balanceMoney.asObservable()
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()

    private let expectedBalance: MoneyValue

    // MARK: - Setup

    public init(expectedBalance: MoneyValue) {
        self.expectedBalance = expectedBalance
    }
}

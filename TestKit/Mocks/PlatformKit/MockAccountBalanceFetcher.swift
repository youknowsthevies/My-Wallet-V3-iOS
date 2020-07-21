//
//  MockAccountBalanceFetcher.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 16/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

import PlatformKit

public final class MockAccountBalanceFetcher: AccountBalanceFetching {

    public var balanceType: BalanceType {
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

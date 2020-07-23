//
//  CustodialMoneyBalanceFetcher.swift
//  PlatformKit
//
//  Created by Daniel on 07/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public final class CustodialMoneyBalanceFetcher: CustodialAccountBalanceFetching {

    // MARK: - Public Properties
    
    public var balanceType: BalanceType {
        _ = setup
        return fetcher.balanceType
    }
    
    public var balanceMoney: Single<MoneyValue> {
        balanceMoneyObservable
            .take(1)
            .asSingle()
    }
     
    public var balanceMoneyObservable: Observable<MoneyValue> {
        _ = setup
        let currencyType = self.currencyType
        return balanceRelay.map { $0 ?? .zero(currencyType) }
    }

    public var isFunded: Observable<Bool> {
        _ = setup
        return balanceRelay.map { $0 != nil }
    }
    
    public var fundsState: Observable<AccountBalanceState<MoneyValue>> {
        isFunded
            .flatMap(weak: self) { (self, isFunded) in
                guard isFunded else {
                    return .just(.absent)
                }
                return self.balanceMoneyObservable.map { .present($0) }
            }
    }

    public var balanceFetchTriggerRelay: PublishRelay<Void> {
        _ = setup
        return fetcher.balanceFetchTriggerRelay
    }

    // MARK: - Private Properties

    private let balanceRelay: BehaviorRelay<MoneyValue?>
    private let currencyType: CurrencyType
    private let disposeBag = DisposeBag()
    private let fetcher: CustodialBalanceStatesFetcherAPI
    
    private lazy var setup: Void = {
        let currencyType = self.currencyType
        fetcher.balanceStatesObservable
            .map { $0[currencyType].balance?.available }
            .catchErrorJustReturn(nil)
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: Init

    public init(currencyType: CurrencyType,
                fetcher: CustodialBalanceStatesFetcherAPI) {
        self.balanceRelay = BehaviorRelay(value: nil)
        self.fetcher = fetcher
        self.currencyType = currencyType
    }
}

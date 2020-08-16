//
//  BuyActivityItemEventService.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift

final class BuyActivityItemEventService: BuyActivityItemEventServiceAPI {
    
    var state: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return stateRelay
            .catchErrorJustReturn(.loaded(next: []))
            .asObservable()
    }
    
    var buyActivityEvents: Single<[BuyActivityItemEvent]> {
        _ = setup
        return _buyActivityEvents
    }
    
    var buyActivityObservable: Observable<[BuyActivityItemEvent]> {
        _ = setup
        return _buyActivityObservable
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private var _buyActivityEvents: Single<[BuyActivityItemEvent]> {
        custodialFeatureFetching
            .featureEnabled(for: .simpleBuyEnabled)
            .flatMap(weak: self) { (self, simpleBuyEnabled) in
                guard simpleBuyEnabled else {
                    return Single.just([])
                }
                return self.fetchBuyActivityEvents
            }
    }
    
    private var _buyActivityObservable: Observable<[BuyActivityItemEvent]> {
        _buyActivityEvents
            .catchErrorJustReturn([])
            .asObservable()
    }
    
    private var fetchBuyActivityEvents: Single<[BuyActivityItemEvent]> {
        service
            .orders
            .map(weak: self) { (self, orders) -> [OrderDetails] in
                orders.filter {
                    $0.cryptoValue.currencyType == self.currency
                }
            }
            .map { items in items.filter { $0.cryptoValue.currencyType == self.currency } }
            .map { items in items.map { BuyActivityItemEvent.init(with: $0) } }
    }

    private lazy var setup: Void = {
        Observable.combineLatest(
                _buyActivityObservable,
                fetchTriggerRelay
            )
            .map { $0.0 }
            .map { items in items.map { .buy($0) } }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let buyActivityRelay = BehaviorRelay<[BuyActivityItemEvent]>(value: [])
    private let currency: CryptoCurrency
    private let service: BuySellKit.OrdersServiceAPI
    private let disposeBag = DisposeBag()
    private let custodialFeatureFetching: CustodialFeatureFetching

    init(currency: CryptoCurrency,
         service: BuySellKit.OrdersServiceAPI,
         custodialFeatureFetching: CustodialFeatureFetching = resolve()) {
        self.currency = currency
        self.service = service
        self.custodialFeatureFetching = custodialFeatureFetching
    }
}

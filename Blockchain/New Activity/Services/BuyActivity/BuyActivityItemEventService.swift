//
//  BuyActivityItemEventService.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxRelay
import RxSwift

final class BuyActivityItemEventService: BuyActivityItemEventServiceAPI {
    
    var state: Observable<ActivityItemEventsLoadingState> {
        stateRelay
            .asObservable()
    }
    
    var buyActivityEvents: Single<[BuyActivityItemEvent]> {
        custodialFeatureFetching
            .featureEnabled(for: .simpleBuyEnabled)
            .flatMap(weak: self) { (self, simpleBuyEnabled) in
                guard simpleBuyEnabled else {
                    return Single.just([])
                }
                return self.fetchBuyActivityEvents
            }
    }
    
    var buyActivityObservable: Observable<[BuyActivityItemEvent]> {
        buyActivityEvents.asObservable()
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let buyActivityRelay = BehaviorRelay<[BuyActivityItemEvent]>(value: [])
    private let currency: CryptoCurrency
    private let service: BuySellKit.OrdersServiceAPI
    private let disposeBag = DisposeBag()
    private let custodialFeatureFetching: CustodialFeatureFetching

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

    init(currency: CryptoCurrency,
         service: BuySellKit.OrdersServiceAPI,
         tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         featureFetching: FeatureFetching = AppFeatureConfigurator.shared) {
        self.currency = currency
        self.service = service
        custodialFeatureFetching = CustodialFeatureFetcher(tiersService: tiersService, featureFetching: featureFetching)
        
        Observable.combineLatest(
                buyActivityObservable,
                fetchTriggerRelay
            )
            .map { $0.0 }
            .map { items in items.map { .buy($0) } }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

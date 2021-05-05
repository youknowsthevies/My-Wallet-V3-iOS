// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

final class BuySellActivityItemEventService: BuySellActivityItemEventServiceAPI {
    
    var state: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return stateRelay
            .catchErrorJustReturn(.loaded(next: []))
            .asObservable()
    }
    
    var buySellActivityEvents: Single<[BuySellActivityItemEvent]> {
        _ = setup
        return _buySellActivityEvents
    }
    
    var buySellActivityObservable: Observable<[BuySellActivityItemEvent]> {
        _ = setup
        return _buySellActivityObservable
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private var _buySellActivityEvents: Single<[BuySellActivityItemEvent]> {
        kycTiersService
            .tiers
            .map(\.isTier2Approved)
            .flatMap(weak: self) { (self, tier2Approved) in
                guard tier2Approved else {
                    return Single.just([])
                }
                return self.fetchBuySellActivityEvents
            }
    }
    
    private var _buySellActivityObservable: Observable<[BuySellActivityItemEvent]> {
        _buySellActivityEvents
            .catchErrorJustReturn([])
            .asObservable()
    }
    
    private var fetchBuySellActivityEvents: Single<[BuySellActivityItemEvent]> {
        service
            .fetchOrders()
            .map(weak: self) { (self, orders) -> [OrderDetails] in
                orders.filter {
                    $0.outputValue.currencyType == self.currencyType || $0.inputValue.currencyType == self.currencyType
                }
            }
            .map { items in items.map { BuySellActivityItemEvent(with: $0) } }
    }

    private lazy var setup: Void = {
        fetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                self._buySellActivityObservable
            }
            .map { items in items.map { .buySell($0) } }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let buySellActivityRelay = BehaviorRelay<[BuySellActivityItemEvent]>(value: [])
    private let currencyType: CurrencyType
    private let service: OrdersServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let disposeBag = DisposeBag()

    init(currency: CryptoCurrency,
         service: OrdersServiceAPI,
         kycTiersSerivice: KYCTiersServiceAPI = resolve()) {
        self.currencyType = .crypto(currency)
        self.service = service
        self.kycTiersService = kycTiersSerivice
    }
}

//
//  FiatActivityItemEventService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public final class FiatActivityItemEventService: FiatActivityItemEventServiceAPI {
    
    public var fiatActivityEvents: Single<[FiatActivityItemEvent]> {
        _ = setup
        return fetcher
            .fiatActivity(fiatCurrency: fiatCurrency)
            .map { $0.filter { $0.type != .unknown } }
    }
    
    public var fiatActivityObservable: Observable<[FiatActivityItemEvent]> {
        _ = setup
        return fiatActivityEvents
            .asObservable()
    }
    
    public var state: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return stateRelay
            .catchErrorJustReturn(.loaded(next: []))
            .asObservable()
    }
    
    public let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        fetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                self.fiatActivityObservable
            }
            .map { items in items.map { ActivityItemEvent.fiat($0) } }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let fetcher: FiatActivityItemEventFetcherAPI
    private let fiatCurrency: FiatCurrency
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    public init(fetcher: FiatActivityItemEventFetcherAPI,
                fiatCurrency: FiatCurrency) {
        self.fetcher = fetcher
        self.fiatCurrency = fiatCurrency
    }
}

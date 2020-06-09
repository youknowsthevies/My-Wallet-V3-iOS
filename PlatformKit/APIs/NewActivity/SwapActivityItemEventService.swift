//
//  SwapActivityItemEventService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public class SwapActivityItemEventService: SwapActivityItemEventServiceAPI {
    
    // MARK: - Public Properties
    
    public var swapActivityEvents: Single<[SwapActivityItemEvent]> {
        fiatCurrencyProvider
            .fiatCurrency
            .map { $0.code }
            .flatMap(weak: self) { (self, currencyCode) -> Single<[SwapActivityItemEvent]> in
                self.fetcher
                    .fetchSwapActivityEvents(
                        date: Date(),
                        fiatCurrency: currencyCode
                    )
                    .map { $0.items }
            }
    }
    
    public var swapActivityObservable: Observable<[SwapActivityItemEvent]> {
        swapActivityEvents.asObservable()
    }
    
    public var state: Observable<ActivityItemEventsLoadingState> {
        stateRelay.asObservable()
    }
    
    public let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let fetcher: SwapActivityItemEventFetcherAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(fetcher: SwapActivityItemEventFetcherAPI,
                fiatCurrencyProvider: FiatCurrencySettingsServiceAPI) {
        self.fetcher = fetcher
        self.fiatCurrencyProvider = fiatCurrencyProvider
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        
        let fiatCurrencyCode = fiatCurrencyProvider
            .fiatCurrencyObservable
            .map { $0.code }
        
        Observable
            .combineLatest(
                fiatCurrencyCode,
                fetchTriggerRelay
            )
            .throttle(.milliseconds(100), scheduler: scheduler)
            .flatMap(weak: self) { (self, values) -> Observable<[SwapActivityItemEvent]> in
                self.fetcher.fetchSwapActivityEvents(date: Date(), fiatCurrency: values.0)
                    .asObservable()
                    .map { $0.items }
            }
            .map { items in items.map { .swap($0) } }
            .map { .loaded(next: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}


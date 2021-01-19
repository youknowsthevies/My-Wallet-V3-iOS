//
//  SwapActivityItemEventService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxRelay
import RxSwift
import ToolKit

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
    
    public var custodial: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return custodialRelay.asObservable()
    }
    
    public var nonCustodial: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return onChainRelay.asObservable()
    }
    
    public var state: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return Observable.combineLatest(custodial, nonCustodial)
            .map { values -> [ActivityItemEvent] in
                let (a, b) = values
                let custodial = a.value ?? []
                let nonCustodial = b.value ?? []
                return custodial + nonCustodial
            }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
    }
    
    public let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let fetcher: SwapActivityItemEventFetcherAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    private let onChainRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let custodialRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    private lazy var setup: Void = {
        let fiatCurrencyCode = fiatCurrencyProvider
            .fiatCurrencyObservable
            .map { $0.code }
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        
        let activityItems = Observable
            .combineLatest(
                fiatCurrencyCode,
                fetchTriggerRelay
            )
            .throttle(.milliseconds(100), scheduler: scheduler)
            .flatMap(weak: self) { (self, values) -> Observable<[SwapActivityItemEvent]> in
                self.fetcher.fetchSwapActivityEvents(date: Date(), fiatCurrency: values.0)
                    .asObservable()
                    .catchErrorJustReturn(.init(hasNextPage: false, items: []))
                    .map { $0.items }
            }
        
        let onChain: Observable<[ActivityItemEvent]> = activityItems
            .map { items -> [SwapActivityItemEvent] in
                items.filter(\.isNonCustodial)
            }
            .map { items in items.map { .swap($0) } }
        
        let custodial: Observable<[ActivityItemEvent]> = activityItems
            .map { items -> [SwapActivityItemEvent] in
                items.filter(\.isCustodial)
            }
            .map { items in items.map { .swap($0) } }
        
        onChain
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: onChainRelay)
            .disposed(by: disposeBag)
        
        custodial
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: custodialRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Init
    
    public init(fetcher: SwapActivityItemEventFetcherAPI,
                fiatCurrencyProvider: FiatCurrencySettingsServiceAPI = resolve()) {
        self.fetcher = fetcher
        self.fiatCurrencyProvider = fiatCurrencyProvider
    }
}


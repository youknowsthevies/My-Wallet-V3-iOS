//
//  ActivityItemEventServiceAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

final class ActivityItemEventService: ActivityItemEventServiceAPI {
    
    var activityEvents: Single<[ActivityItemEvent]> {
        fetcher
            .activityEvents
            .catchErrorJustReturn([])
    }
    
    var activityObservable: Observable<[ActivityItemEvent]> {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        return fetchTriggerRelay
            .throttle(.milliseconds(100), scheduler: scheduler)
            .flatMapLatest(weak: self) { (self, _) in
                self.activityEvents.asObservable()
            }
    }
    
    var activityLoadingStateObservable: Observable<ActivityItemEventsLoadingState> {
        activityObservable
            .map { .loaded(next: $0) }
            .startWith(.loading)
    }
    
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> {
        activityEvents
            .map { events -> [TransactionalActivityItemEvent] in
                events.compactMap {
                    guard case let .transactional(model) = $0 else { return nil }
                    return model
                }
            }
    }
    
    var transactionActivityObservable: Observable<ActivityItemEventsLoadingState> {
        activityObservable
            .map { events -> [ActivityItemEvent] in
                events.compactMap {
                    guard case .transactional = $0 else { return nil }
                    return $0
                }
            }
            .map { .loaded(next: $0) }
            .startWith(.loading)
    }
    
    /// A trigger for a fetch
    let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let fetcher: ActivityItemEventFetcherAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let fiatCurrencySettingsAPI: FiatCurrencySettingsServiceAPI
    
    // MARK: - Setup
    
    init(fetcher: ActivityItemEventFetcherAPI,
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        self.fetcher = fetcher
        self.authenticationService = authenticationService
        self.fiatCurrencySettingsAPI = fiatCurrencyService
    }
}

//
//  TransactionalActivityItemEventService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public class TransactionalActivityItemEventService: TransactionalActivityItemEventServiceAPI {
    
    // MARK: - Public Properties
    
    public var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> {
        fetcher
            .fetchTransactionalActivityEvents(
                token: nil,
                limit: pageSize
            )
            .map { $0.items }
            .catchErrorJustReturn([])
    }
    
    public var transactionActivityObservable: Observable<[TransactionalActivityItemEvent]> {
        transactionActivityEvents
            .asObservable()
    }
    
    public var state: Observable<ActivityItemEventsLoadingState> {
        stateRelay
            .catchErrorJustReturn(.loaded(next: []))
            .asObservable()
    }
    
    public let fetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let fetcher: TransactionalActivityItemEventFetcherAPI
    private let stateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(fetcher: TransactionalActivityItemEventFetcherAPI) {
        self.fetcher = fetcher
        
        fetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                self.transactionActivityObservable
            }
            .map { items in items.map { ActivityItemEvent.transactional($0) } }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

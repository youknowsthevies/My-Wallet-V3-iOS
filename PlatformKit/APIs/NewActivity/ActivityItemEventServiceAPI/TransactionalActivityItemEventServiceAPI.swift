//
//  TransactionalActivityItemEventServiceAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol TransactionalActivityItemEventServiceAPI {
    var pageSize: Int { get }
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> { get }
    var transactionActivityObservable: Observable<[TransactionalActivityItemEvent]> { get }
    var state: Observable<ActivityItemEventsLoadingState> { get }
    
    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

extension TransactionalActivityItemEventServiceAPI {
    public var pageSize: Int {
        50
    }
}

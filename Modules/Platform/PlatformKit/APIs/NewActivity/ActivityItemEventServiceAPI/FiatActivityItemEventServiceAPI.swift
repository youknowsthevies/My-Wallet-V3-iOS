// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol FiatActivityItemEventServiceAPI {
    var fiatActivityEvents: Single<[FiatActivityItemEvent]> { get }
    var fiatActivityObservable: Observable<[FiatActivityItemEvent]> { get }
    var state: Observable<ActivityItemEventsLoadingState> { get }
    
    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}


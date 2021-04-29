// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol BuySellActivityItemEventServiceAPI {
    var buySellActivityEvents: Single<[BuySellActivityItemEvent]> { get }
    var buySellActivityObservable: Observable<[BuySellActivityItemEvent]> { get }
    var state: Observable<ActivityItemEventsLoadingState> { get }
    
    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

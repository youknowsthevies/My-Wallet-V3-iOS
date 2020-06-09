//
//  SwapActivityItemEventServiceAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol SwapActivityItemEventServiceAPI {
    var swapActivityEvents: Single<[SwapActivityItemEvent]> { get }
    var swapActivityObservable: Observable<[SwapActivityItemEvent]> { get }
    var state: Observable<ActivityItemEventsLoadingState> { get }
    
    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

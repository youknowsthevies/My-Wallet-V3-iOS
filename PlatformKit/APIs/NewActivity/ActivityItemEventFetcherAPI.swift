//
//  ActivityItemEventFetcherAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 5/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol TransactionalActivityItemEventFetcherAPI {
    func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageResult<TransactionalActivityItemEvent>>
}

public protocol SwapActivityItemEventFetcherAPI {
    func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>>
}

public protocol ActivityItemEventFetcherAPI {
    var fiatCurrencyProvider: FiatCurrencySettingsServiceAPI { get }
    var transactionalActivityItemFetcher: TransactionalActivityItemEventFetcherAPI { get }
    var swapActivityItemFetcher: SwapActivityItemEventFetcherAPI { get }
    var pageSize: Int { get }
    var activityEvents: Single<[ActivityItemEvent]> { get }
}

extension ActivityItemEventFetcherAPI {
    public var pageSize: Int {
        50
    }
}

public protocol ActivityItemEventServiceAPI {
    var activityEvents: Single<[ActivityItemEvent]> { get }
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> { get }
    
    var activityObservable: Observable<[ActivityItemEvent]> { get }
    var activityLoadingStateObservable: Observable<ActivityItemEventsLoadingState> { get }
    var transactionActivityObservable: Observable<ActivityItemEventsLoadingState> { get }
    
    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public protocol ActivityItemEventDetailsFetcherAPI: AnyObject {
    associatedtype Model
    func details(for identifier: String) -> Observable<Model>
}

public struct AnyActivityItemEventDetailsFetcher<Model> {

    private let detailsObservable: (String) -> Observable<Model>

    public init<API: ActivityItemEventDetailsFetcherAPI>(api: API) where API.Model == Model {
        detailsObservable = api.details
    }

    public func details(for identifier: String) -> Observable<Model> {
        detailsObservable(identifier)
    }
}

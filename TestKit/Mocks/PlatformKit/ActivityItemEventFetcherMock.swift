//
//  ActivityItemEventFetcherMock.swift
//  TestKit
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

class ActivityItemEventFetcherMock: ActivityItemEventServiceAPI {
    func refresh() {
        transactional.fetchTriggerRelay.accept(())
        swap.fetchTriggerRelay.accept(())
        buy.fetchTriggerRelay.accept(())
    }
    
    var activityLoadingStateObservable: Observable<ActivityItemEventsLoadingState> {
        Observable.just(.loading)
    }
    
    var fetchTriggerRelay = PublishRelay<Void>()
    
    var buy: BuyActivityItemEventServiceAPI = BuyActivityItemEventFetcherMock()
    var swap: SwapActivityItemEventServiceAPI = SwapActivityItemEventServiceMock()
    var transactional: TransactionalActivityItemEventServiceAPI = TransactionalActivityItemEventServiceMock()
    var transactionalActivityItemFetcher: TransactionalActivityItemEventFetcherAPI = TransactionalActivityItemEventFetcherMock()
    var activityEvents: Single<[ActivityItemEvent]> {
        Single.just([])
    }
}

class TransactionalActivityItemEventServiceMock: TransactionalActivityItemEventServiceAPI {
    
    var state: Observable<ActivityItemEventsLoadingState> {
        Observable.just(.loading)
    }
    
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> {
        Single.just([])
    }
    
    var transactionActivityObservable: Observable<[TransactionalActivityItemEvent]> {
        transactionActivityEvents.asObservable()
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
}

class BuyActivityItemEventFetcherMock: BuyActivityItemEventServiceAPI {
    
    var buyActivityObservable: Observable<[BuyActivityItemEvent]> {
        buyActivityEvents.asObservable()
    }
    
    var state: Observable<ActivityItemEventsLoadingState> {
        Observable.just(.loading)
    }
    
    var buyActivityEvents: Single<[BuyActivityItemEvent]> {
        Single.just([])
    }
    
    let fetchTriggerRelay = PublishRelay<Void>()
}

class SwapActivityItemEventServiceMock: SwapActivityItemEventServiceAPI {
    
    var state: Observable<ActivityItemEventsLoadingState> {
        Observable.just(.loading)
    }
    
    var swapActivityEvents: Single<[SwapActivityItemEvent]> {
        Single.just([])
    }
    
    var swapActivityObservable: Observable<[SwapActivityItemEvent]> {
        Observable.just([])
    }
    let fetchTriggerRelay = PublishRelay<Void>()
}

class SwapActivityItemEventFetcherMock: SwapActivityItemEventFetcherAPI {
    func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>> {
        .just(.init(hasNextPage: false, items: []))
    }
}

class TransactionalActivityItemEventFetcherMock: TransactionalActivityItemEventFetcherAPI {
    func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageResult<TransactionalActivityItemEvent>> {
        .just(.init(hasNextPage: false, items: []))
    }
}

//
//  ActivityItemEventFetcherMock.swift
//  TestKit
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

class ActivityItemEventFetcherMock: ActivityItemEventFetcherAPI {
    var fiatCurrencyProvider: FiatCurrencySettingsServiceAPI = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)
    var swapActivityItemFetcher: SwapActivityItemEventFetcherAPI = SwapActivityItemEventFetcherMock()
    var transactionalActivityItemFetcher: TransactionalActivityItemEventFetcherAPI = TransactionalActivityItemEventFetcherMock()
    var activityEvents: Single<[ActivityItemEvent]> {
        Single.just([])
    }
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

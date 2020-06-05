//
//  EthereumActivityItemEventFetcher.swift
//  EthereumKit
//
//  Created by Alex McGregor on 5/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class EthereumActivityItemEventFetcher: ActivityItemEventFetcherAPI {
    
    public var activityEvents: Single<[ActivityItemEvent]> {
        fiatCurrencyProvider.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<[ActivityItemEvent]> in
                Single.zip(
                        self.fetchSwapActivityEvents(fiatCurrencyCode: fiatCurrency.code),
                        self.fetchTransactionActivity()
                    )
                    .map { $0.0 + $0.1 }
            }
    }
    
    public let swapActivityItemFetcher: SwapActivityItemEventFetcherAPI
    public let transactionalActivityItemFetcher: TransactionalActivityItemEventFetcherAPI
    public let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    
    public init(swapActivityEventService: EthereumSwapActivityItemEventsService,
                transactionalActivityEventService: EthereumTransactionalActivityItemEventsService,
                fiatCurrencyProvider: FiatCurrencySettingsServiceAPI) {
        self.swapActivityItemFetcher = swapActivityEventService
        self.transactionalActivityItemFetcher = transactionalActivityEventService
        self.fiatCurrencyProvider = fiatCurrencyProvider
    }
    
    private func fetchTransactionActivity() -> Single<[ActivityItemEvent]> {
        transactionalActivityItemFetcher
            .fetchTransactionalActivityEvents(token: nil, limit: pageSize)
            .map { $0.items }
            .map { $0.map { .transactional($0) } }
    }
    
    private func fetchSwapActivityEvents(fiatCurrencyCode: String) -> Single<[ActivityItemEvent]> {
        swapActivityItemFetcher
            .fetchSwapActivityEvents(date: Date(),
                                     fiatCurrency: fiatCurrencyCode)
            .map { $0.items }
            .map { $0.map { .swap($0) } }
    }
    
}

//
//  AlgorandSwapActivityItemEventsService.swift
//  AlgorandKit
//
//  Created by Alex McGregor on 1/29/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class AlgorandSwapActivityItemEventsService: SwapActivityItemEventFetcherAPI {
    
    private let service: SwapActivityServiceAPI
    
    public init(service: SwapActivityServiceAPI) {
        self.service = service
    }
    
    public func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>> {
        service
            .fetchActivity(
                from: date,
                cryptoCurrency: .algorand
            )
            .map(weak: self) { (self, events) -> PageResult<SwapActivityItemEvent> in
                PageResult(
                    hasNextPage: events.count == self.service.pageSize,
                    items: events
                )
            }
    }
}

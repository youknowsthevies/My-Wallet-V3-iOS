//
//  AnyERC20SwapActivityItemEventsService.swift
//  ERC20Kit
//
//  Created by Alex McGregor on 5/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class AnyERC20SwapActivityItemEventsService<Token: ERC20Token>: SwapActivityItemEventFetcherAPI {
    
    private let service: SwapActivityServiceAPI
    
    public init(service: SwapActivityServiceAPI) {
        self.service = service
    }
    
    public func fetchSwapActivityEvents(date: Date, fiatCurrency: String) -> Single<PageResult<SwapActivityItemEvent>> {
        service
            .fetchActivity(
                    from: date,
                    cryptoCurrency: Token.assetType
                )
                .map(weak: self) { (self, events) -> PageResult<SwapActivityItemEvent> in
                    PageResult(
                        hasNextPage: events.count == self.service.pageSize,
                        items: events
                    )
                }
    }
}

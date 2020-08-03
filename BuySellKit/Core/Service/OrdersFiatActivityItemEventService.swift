//
//  OrdersFiatActivityItemEventService.swift
//  BuySellKit
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class OrdersFiatActivityItemEventService: FiatActivityItemEventFetcherAPI {
    
    private let service: OrdersActivityEventServiceAPI
    
    init(service: OrdersActivityEventServiceAPI) {
        self.service = service
    }
    
    func fiatActivity(fiatCurrency: FiatCurrency) -> Single<[FiatActivityItemEvent]> {
        service.activityResponse(fiatCurrency: fiatCurrency)
            .map { $0.items }
    }
}

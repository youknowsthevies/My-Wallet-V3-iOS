//
//  OrdersActivityEventService.swift
//  BuySellKit
//
//  Created by Alex McGregor on 7/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol OrdersActivityEventServiceAPI: class {
    func activityResponse(fiatCurrency: FiatCurrency) -> Single<OrdersActivityResponse>
}

final class OrdersActivityEventService: OrdersActivityEventServiceAPI {
    
    private let client: OrdersActivityClientAPI
    
    init(client: OrdersActivityClientAPI) {
        self.client = client
    }
    
    func activityResponse(fiatCurrency: FiatCurrency) -> Single<OrdersActivityResponse> {
        client.activityResponse(fiatCurrency: fiatCurrency)
    }
}

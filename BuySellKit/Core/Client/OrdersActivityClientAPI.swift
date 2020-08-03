//
//  OrdersActivityClientAPI.swift
//  BuySellKit
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol OrdersActivityClientAPI: class {

    /// Fetch order activity response
    func activityResponse(fiatCurrency: FiatCurrency) -> Single<OrdersActivityResponse>
}


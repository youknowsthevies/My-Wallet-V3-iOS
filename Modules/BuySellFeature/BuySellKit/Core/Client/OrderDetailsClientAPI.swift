//
//  OrderDetailsClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol OrderDetailsClientAPI: class {

    /// Fetch all Buy/Sell orders
    func orderDetails(pendingOnly: Bool) -> Single<[OrderPayload.Response]>
    
    /// Fetch a single Buy/Sell order
    func orderDetails(with identifier: String) -> Single<OrderPayload.Response>
}

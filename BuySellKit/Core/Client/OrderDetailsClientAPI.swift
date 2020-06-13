//
//  OrderDetailsClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol OrderDetailsClientAPI: class {

    /// Fetch all Buy orders
    func orderDetails(token: String, pendingOnly: Bool) -> Single<[OrderPayload.Response]>
    
    /// Fetch a single Buy order
    func orderDetails(with identifer: String, token: String) -> Single<OrderPayload.Response>
}

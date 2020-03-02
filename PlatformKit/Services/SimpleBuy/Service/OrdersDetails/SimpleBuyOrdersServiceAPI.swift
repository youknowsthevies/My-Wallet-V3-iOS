//
//  SimpleBuyOrdersServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyOrdersServiceAPI: class {

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: Single<[SimpleBuyOrderDetails]> { get }
    
    /// Fetches the orders from remote
    func fetchOrders() -> Single<[SimpleBuyOrderDetails]>
}

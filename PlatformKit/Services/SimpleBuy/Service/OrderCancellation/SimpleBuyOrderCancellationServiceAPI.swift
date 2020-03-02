//
//  SimpleBuyOrderCancellationServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyOrderCancellationServiceAPI: class {
    
    /// Cancels an order associated with the given id
    func cancel(order id: String) -> Completable
}

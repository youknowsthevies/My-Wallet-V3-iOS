//
//  OrderCancellationClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol OrderCancellationClientAPI: class {
    /// Cancels an order with a given identifier
    func cancel(order id: String) -> Completable
}

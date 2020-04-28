//
//  SimpleBuyPendingOrderDetailsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyPendingOrderDetailsServiceAPI: class {
    var checkoutData: Single<SimpleBuyCheckoutData?> { get }
    var pendingOrderDetails: Single<SimpleBuyOrderDetails?> { get }
    var pendingDepositOrderDetails: Single<SimpleBuyOrderDetails?> { get }
    func cancel() -> Completable
}

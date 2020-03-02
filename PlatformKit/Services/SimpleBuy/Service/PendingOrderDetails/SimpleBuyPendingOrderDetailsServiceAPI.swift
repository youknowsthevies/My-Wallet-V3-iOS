//
//  SimpleBuyPendingOrderDetailsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyPendingOrderDetailsServiceAPI: class {
    var orderDetails: Single<SimpleBuyCheckoutData?> { get }
}

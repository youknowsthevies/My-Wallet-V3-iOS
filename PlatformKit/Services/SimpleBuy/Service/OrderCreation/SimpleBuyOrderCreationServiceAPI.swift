//
//  SimpleBuyOrderCreationServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyOrderCreationServiceAPI: class {
    func create(using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyCheckoutData>
}

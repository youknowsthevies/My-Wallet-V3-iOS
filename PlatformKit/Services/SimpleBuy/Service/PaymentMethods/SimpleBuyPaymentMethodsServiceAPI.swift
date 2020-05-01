//
//  SimpleBuyPaymentMethodsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

/// Fetches the available payment methods
public protocol SimpleBuyPaymentMethodsServiceAPI: class {
    var paymentMethods: Observable<[SimpleBuyPaymentMethod]> { get }
    var paymentMethodsSingle: Single<[SimpleBuyPaymentMethod]> { get }
    var supportedCardTypes: Single<Set<CardType>> { get }
}


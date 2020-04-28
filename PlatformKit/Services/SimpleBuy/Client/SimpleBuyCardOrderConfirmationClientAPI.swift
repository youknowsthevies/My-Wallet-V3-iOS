//
//  SimpleBuyOrderConfirmationClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyCardOrderConfirmationClientAPI: class {
    
    /// Confirm an order
    func confirmOrder(with identifier: String,
                      partner: SimpleBuyOrderPayload.ConfirmOrder.Partner,
                      token: String) -> Single<SimpleBuyOrderPayload.Response>
}


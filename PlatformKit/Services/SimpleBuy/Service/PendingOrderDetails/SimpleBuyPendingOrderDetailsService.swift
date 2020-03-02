//
//  SimpleBuyPendingOrderDetailsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class SimpleBuyPendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI {
    
    public var orderDetails: Single<SimpleBuyCheckoutData?> {
        ordersService.orders
            .map { $0.pendingDeposit.first }
            .flatMap(weak: self) { (self, pendingOrder) in
                guard let pendingOrder = pendingOrder else {
                    return .just(nil)
                }
                let checkoutData = SimpleBuyCheckoutData(orderDetails: pendingOrder)
                return self.paymentAccountService.paymentAccount(for: pendingOrder.fiatValue.currency)
                    .map { checkoutData.checkoutData(byAppending: $0) }
            }
    }
    
    // MARK: - Injected
    
    private let ordersService: SimpleBuyOrdersServiceAPI
    private let paymentAccountService: SimpleBuyPaymentAccountServiceAPI
    
    // MARK: - Setup
    
    public init(ordersService: SimpleBuyOrdersServiceAPI,
                paymentAccountService: SimpleBuyPaymentAccountServiceAPI) {
        self.ordersService = ordersService
        self.paymentAccountService = paymentAccountService
    }
}

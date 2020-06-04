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
    
    public var checkoutData: Single<SimpleBuyCheckoutData?> {
        pendingOrderDetails
            .flatMap(weak: self) { (self, pendingOrder) in
                guard let pendingOrder = pendingOrder else {
                    return .just(nil)
                }
                let checkoutData = SimpleBuyCheckoutData(orderDetails: pendingOrder)
                if pendingOrder.isBankWire {
                    return self.paymentAccountService.paymentAccount(for: pendingOrder.fiatValue.currency)
                        .map { checkoutData.checkoutData(byAppending: $0) }
                } else {
                    return .just(checkoutData)
                }
            }
    }
    
    public var pendingOrderDetails: Single<SimpleBuyOrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction || $0.is3DSConfirmedCardOrder }
            }
            .map { $0.first }
    }
    
    public var pendingActionOrderDetails: Single<SimpleBuyOrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction }
            }
            .map { $0.first }
    }
    
    // MARK: - Injected
    
    private let paymentAccountService: SimpleBuyPaymentAccountServiceAPI
    private let ordersService: SimpleBuyOrdersServiceAPI
    private let cancallationService: SimpleBuyOrderCancellationServiceAPI
    
    // MARK: - Setup
    
    public init(paymentAccountService: SimpleBuyPaymentAccountServiceAPI,
                ordersService: SimpleBuyOrdersServiceAPI,
                cancallationService: SimpleBuyOrderCancellationServiceAPI) {
        self.paymentAccountService = paymentAccountService
        self.ordersService = ordersService
        self.cancallationService = cancallationService
    }
    
    public func cancel() -> Completable {
        pendingOrderDetails
            .flatMapCompletable(weak: self) { (self, details) -> Completable in
                guard let details = details else { return .empty() }
                return self.cancallationService.cancel(order: details.identifier)
            }
    }
}

//
//  SimpleBuyStateServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit
import BuySellKit

/// A passive state receiver API for Simple-Buy flow.
public protocol SimpleBuyStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<SimpleBuyStateService.Action> { get }
}

/// A checkout service API
public protocol SimpleBuyCheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    var previousRelay: PublishRelay<Void> { get }
    func nextFromBuyCrypto(with checkoutData: CheckoutData)
    func ineligible(with checkoutData: CheckoutData)
    func kyc(with checkoutData: CheckoutData)
    func addCardStateService(with checkoutData: CheckoutData) -> AddCardStateService
    func paymentMethods()
    func changeCurrency()
    func currencySelected()
    func reselectCurrency()
}

public protocol SimpleBuyElibilityRelayAPI: RoutingPreviousStateEmitterAPI {
    func ineligible(with currency: FiatCurrency)
}

/// A confirm-checkout service API
public protocol SimpleBuyTransferDetailsServiceAPI: RoutingPreviousStateEmitterAPI {
    func transferDetails(with checkoutData: CheckoutData)
}

/// A confirm-checkout service API
public protocol SimpleBuyConfirmCheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    /// - parameter isOrderNew: Bool flag representing if the given `SimpleBuyCheckoutData` is from a newly created order
    /// or if it is from an existing order.
    func confirmCheckout(with checkoutData: CheckoutData, isOrderNew: Bool)
}

/// A cancellation service API
public protocol SimpleBuyCancelTransferServiceAPI: RoutingPreviousStateEmitterAPI {
    func cancelTransfer(with checkoutData: CheckoutData)
}

public protocol SimpleBuyCurrencySelectionServiceAPI {
    func currencySelected()
    func reselectCurrency()
}

public protocol SimpleBuyStateCacheProviderAPI: class {
    var cache: EventCache { get }
}

public protocol PendingOrderCompletionStateServiceAPI: class {
    func orderPending(with orderDetails: OrderDetails)
    func orderCompleted()
}

/// A composition of all of Simple-Buy state-services
public typealias SimpleBuyStateServiceAPI = RoutingStateEmitterAPI &
                                            SimpleBuyStateReceiverServiceAPI &
                                            SimpleBuyTransferDetailsServiceAPI &
                                            SimpleBuyConfirmCheckoutServiceAPI &
                                            SimpleBuyStateCacheProviderAPI &
                                            SimpleBuyCheckoutServiceAPI &
                                            SimpleBuyCancelTransferServiceAPI &
                                            SimpleBuyCurrencySelectionServiceAPI &
                                            CardAuthorizationStateServiceAPI &
                                            PendingOrderCompletionStateServiceAPI &
                                            SimpleBuyElibilityRelayAPI

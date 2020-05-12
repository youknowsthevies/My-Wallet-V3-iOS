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

/// Emits a command to return to the previous state
protocol RoutingPreviousStateEmitterAPI: class {
    /// Move to the previous state
    var previousRelay: PublishRelay<Void> { get }
}

/// Emits a command to move forward to the next state
protocol RoutingNextStateEmitterAPI: class {
    /// Move to the next state
    var nextRelay: PublishRelay<Void> { get }
}

/// Emits both previus and next state commands. Exposes a simple navigation API
typealias RoutingStateEmitterAPI = RoutingPreviousStateEmitterAPI & RoutingNextStateEmitterAPI

/// A passive state receiver API for Simple-Buy flow.
protocol SimpleBuyStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<SimpleBuyStateService.Action> { get }
}

/// A checkout service API
protocol SimpleBuyCheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    var previousRelay: PublishRelay<Void> { get }
    func nextFromBuyCrypto(with checkoutData: SimpleBuyCheckoutData)
    func ineligible(with checkoutData: SimpleBuyCheckoutData)
    func kyc(with checkoutData: SimpleBuyCheckoutData)
    func addCardStateService(with checkoutData: SimpleBuyCheckoutData) -> AddCardStateService
    func paymentMethods()
    func changeCurrency()
    func currencySelected()
    func reselectCurrency()
}

protocol SimpleBuyElibilityRelayAPI: RoutingPreviousStateEmitterAPI {
    func ineligible(with currency: FiatCurrency)
}

/// A confirm-checkout service API
protocol SimpleBuyTransferDetailsServiceAPI: RoutingPreviousStateEmitterAPI {
    func transferDetails(with checkoutData: SimpleBuyCheckoutData)
}

/// A confirm-checkout service API
protocol SimpleBuyConfirmCheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    /// - parameter isOrderNew: Bool flag representing if the given `SimpleBuyCheckoutData` is from a newly created order
    /// or if it is from an existing order.
    func confirmCheckout(with checkoutData: SimpleBuyCheckoutData, isOrderNew: Bool)
}

/// A cancellation service API
protocol SimpleBuyCancelTransferServiceAPI: RoutingPreviousStateEmitterAPI {
    func cancelTransfer(with checkoutData: SimpleBuyCheckoutData)
}

protocol SimpleBuyCurrencySelectionServiceAPI {
    func currencySelected()
    func reselectCurrency()
}

protocol SimpleBuyStateCacheProviderAPI: class {
    var cache: SimpleBuyEventCache { get }
}

protocol PendingOrderCompletionStateServiceAPI: class {
    func orderPending(with orderDetails: SimpleBuyOrderDetails)
    func orderCompleted()
}

/// A composition of all of Simple-Buy state-services
typealias SimpleBuyStateServiceAPI = RoutingStateEmitterAPI &
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

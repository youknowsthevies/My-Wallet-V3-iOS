//
//  StateServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

/// A passive state receiver API for Simple-Buy flow.
public protocol StateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<StateService.Action> { get }
}

/// A checkout service API
public protocol CheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    var previousRelay: PublishRelay<Void> { get }
    func nextFromBuyCrypto(with checkoutData: CheckoutData)
    func ineligible(with checkoutData: CheckoutData)
    func ineligible()
    func kyc(with checkoutData: CheckoutData)
    func cardRoutingInteractor(with checkoutData: CheckoutData, cardServiceProvider: CardServiceProviderAPI) -> CardRouterInteractor
    func paymentMethods()
    func changeCurrency()
    func currencySelected()
    func reselectCurrency()
}

public protocol PaymentMethodsStateAPI: RoutingPreviousStateEmitterAPI {
    func showFundsTransferDetails(for fiatCurrency: FiatCurrency, isOriginDeposit: Bool)
    func kyc()
}

public protocol ElibilityRelayAPI: RoutingPreviousStateEmitterAPI {
    func ineligible(with currency: FiatCurrency)
}

/// A confirm-checkout service API
public protocol TransferDetailsServiceAPI: RoutingPreviousStateEmitterAPI {
    func bankTransferDetails(with checkoutData: CheckoutData)
}

/// A confirm-checkout service API
public protocol ConfirmCheckoutServiceAPI: RoutingPreviousStateEmitterAPI {
    /// - parameter isOrderNew: Bool flag representing if the given `CheckoutData` is from a newly created order
    /// or if it is from an existing order.
    func confirmCheckout(with checkoutData: CheckoutData, isOrderNew: Bool)
}

/// A cancellation service API
public protocol CancelTransferServiceAPI: RoutingPreviousStateEmitterAPI {
    func cancelTransfer(with checkoutData: CheckoutData)
}

public protocol CurrencySelectionServiceAPI {
    func currencySelected()
    func reselectCurrency()
}

public protocol StateCacheProviderAPI: class {
    var cache: EventCache { get }
}

public protocol PendingOrderCompletionStateServiceAPI: class {
    func orderPending(with orderDetails: OrderDetails)
    func orderCompleted()
}

/// A composition of all of Simple-Buy state-services
public typealias StateServiceAPI = RoutingStateEmitterAPI &
                                   StateReceiverServiceAPI &
                                   TransferDetailsServiceAPI &
                                   ConfirmCheckoutServiceAPI &
                                   StateCacheProviderAPI &
                                   CheckoutServiceAPI &
                                   CancelTransferServiceAPI &
                                   CurrencySelectionServiceAPI &
                                   CardAuthorizationRoutingInteractorAPI &
                                   PendingOrderCompletionStateServiceAPI &
                                   ElibilityRelayAPI &
                                   PaymentMethodsStateAPI

//
//  SimpleBuyServiceProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol SimpleBuyServiceProviderAPI: class {
    var supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI { get }
    var supportedPairs: SimpleBuySupportedPairsServiceAPI { get }
    var suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI { get }
    var ordersDetails: SimpleBuyOrdersServiceAPI { get }
    var pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI { get }
    var flowAvailability: SimpleBuyFlowAvailabilityServiceAPI { get }
    var availability: SimpleBuyAvailabilityServiceAPI { get }
    var eligibility: SimpleBuyEligibilityServiceAPI { get }
    var orderCancellation: SimpleBuyOrderCancellationServiceAPI { get }
    var orderConfirmation: SimpleBuyOrderConfirmationServiceAPI { get }
    var paymentMethods: SimpleBuyPaymentMethodsServiceAPI { get }
    var paymentMethodTypes: SimpleBuyPaymentMethodTypesService { get }
    var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI { get }
    
    var cache: SimpleBuyEventCache { get }
    
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI { get }
    var dataRepository: DataRepositoryAPI { get }
    
    func orderCreation(for paymentMethod: SimpleBuyPaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI
}

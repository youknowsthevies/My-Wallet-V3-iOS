//
//  SimpleBuyServiceProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol SimpleBuyServiceProviderAPI: class {
    var eligibility: SimpleBuyEligibilityServiceAPI { get }
    var orderCancellation: SimpleBuyOrderCancellationServiceAPI { get }
    var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI { get }
    var orderConfirmation: SimpleBuyOrderConfirmationServiceAPI { get }
    var ordersDetails: SimpleBuyOrdersServiceAPI { get }
    var paymentMethods: SimpleBuyPaymentMethodsServiceAPI { get }
    var paymentMethodTypes: SimpleBuyPaymentMethodTypesService { get }
    var pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI { get }
    var suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI { get }
    var supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI { get }
    var supportedPairs: SimpleBuySupportedPairsServiceAPI { get }
    var supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI { get }
    
    var cache: SimpleBuyEventCache { get }
    
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI { get }
    var dataRepository: DataRepositoryAPI { get }
    
    func orderCreation(for paymentMethod: SimpleBuyPaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI
}

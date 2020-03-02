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
    var availability: SimpleBuyAvailabilityServiceAPI { get }
    var eligibility: SimpleBuyEligibilityServiceAPI { get }
    var orderCreation: SimpleBuyOrderCreationServiceAPI { get }
    var orderCancellation: SimpleBuyOrderCancellationServiceAPI { get }
    var paymentAccount: SimpleBuyPaymentAccountServiceAPI { get }
    var orderQuote: SimpleBuyOrderQuoteServiceAPI { get }
    var cache: SimpleBuyEventCache { get }
    
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI { get }
    var dataRepository: DataRepositoryAPI { get }
}

//
//  ServiceProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol ServiceProviderAPI: class {
    var eligibility: EligibilityServiceAPI { get }
    var fiatActivity: FiatActivityItemEventFetcherAPI { get }
    var orderCancellation: OrderCancellationServiceAPI { get }
    var orderCompletion: PendingOrderCompletionServiceAPI { get }
    var orderConfirmation: OrderConfirmationServiceAPI { get }
    var ordersDetails: OrdersServiceAPI { get }
    var paymentMethods: PaymentMethodsServiceAPI { get }
    var paymentMethodTypes: PaymentMethodTypesServiceAPI { get }
    var pendingOrderDetails: PendingOrderDetailsServiceAPI { get }
    var suggestedAmounts: SuggestedAmountsServiceAPI { get }
    var supportedCurrencies: SupportedCurrenciesServiceAPI { get }
    var supportedPairs: SupportedPairsServiceAPI { get }
    var supportedPairsInteractor: SupportedPairsInteractorServiceAPI { get }

    var orderCreation: OrderCreationServiceAPI { get }
    var orderQuote: OrderQuoteServiceAPI { get }
    var paymentAccount: PaymentAccountServiceAPI { get }
    
    var beneficiaries: BeneficiariesServiceAPI { get }
    
    var cache: EventCache { get }
    
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI { get }
    var dataRepository: DataRepositoryAPI { get }
    
    func orderCreation(for paymentMethod: PaymentMethod.MethodType) -> PendingOrderCreationServiceAPI
}

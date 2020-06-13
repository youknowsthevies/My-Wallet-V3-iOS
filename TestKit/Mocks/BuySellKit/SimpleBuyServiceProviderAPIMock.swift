//
//  SimpleBuyServiceProviderAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
@testable import PlatformKit
@testable import BuySellKit

final class SimpleBuyServiceProviderAPIMock: ServiceProviderAPI {
    
    var underlyingOrderCompletion: SimpleBuyPendingOrderCompletionServiceAPI!
    var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI {
        underlyingOrderCompletion
    }
    
    var underlyingOrderConfirmation: SimpleBuyOrderConfirmationServiceAPI!
    var orderConfirmation: SimpleBuyOrderConfirmationServiceAPI {
        underlyingOrderConfirmation
    }
    
    var underlyingPendingOrderCreation: SimpleBuyPendingOrderCreationServiceAPI!
    func orderCreation(for paymentMethod: PaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI {
        underlyingPendingOrderCreation
    }
    
    var cache: EventCache = .init(cacheSuite: UserDefaults.standard)
    
    var underlyingRepository: DataRepositoryAPI!
    var dataRepository: DataRepositoryAPI {
        underlyingRepository
    }
    
    var underlyingSupportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI!
    var supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI {
        underlyingSupportedPairsInteractor
    }
    
    var underlyingSupportedPairs: SimpleBuySupportedPairsServiceAPI!
    var supportedPairs: SimpleBuySupportedPairsServiceAPI {
        underlyingSupportedPairs
    }

    var underlyingSuggestedAmounts: SimpleBuySuggestedAmountsServiceAPI!
    var suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI {
        underlyingSuggestedAmounts
    }

    var underlyingOrdersDetails: SimpleBuyOrdersServiceAPI!
    var ordersDetails: SimpleBuyOrdersServiceAPI {
        underlyingOrdersDetails
    }

    var underlyingSettings: (FiatCurrencySettingsServiceAPI & SettingsServiceAPI)!
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI {
        underlyingSettings
    }

    var underlyingSupportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI!
    var supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI {
        underlyingSupportedCurrencies
    }
    
    var underlyingEligibility: SimpleBuyEligibilityServiceAPI!
    var eligibility: SimpleBuyEligibilityServiceAPI {
        underlyingEligibility
    }

    var underlyingOrderCreation: SimpleBuyOrderCreationServiceAPI!
    var orderCreation: SimpleBuyOrderCreationServiceAPI {
        underlyingOrderCreation
    }

    var underlyingPaymentAccount: SimpleBuyPaymentAccountServiceAPI!
    var paymentAccount: SimpleBuyPaymentAccountServiceAPI {
        underlyingPaymentAccount
    }

    var underlyingOrderQuote: SimpleBuyOrderQuoteServiceAPI!
    var orderQuote: SimpleBuyOrderQuoteServiceAPI {
        underlyingOrderQuote
    }
    
    var underlyingPendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI!
    var pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI {
        underlyingPendingOrderDetails
    }
    
    var underlyingoOrderCancellation: SimpleBuyOrderCancellationServiceAPI!
    var orderCancellation: SimpleBuyOrderCancellationServiceAPI {
        underlyingoOrderCancellation
    }
    
    var underlyingPaymentMethods: SimpleBuyPaymentMethodsServiceAPI!
    var paymentMethods: SimpleBuyPaymentMethodsServiceAPI {
        underlyingPaymentMethods
    }
    
    var underlyingPaymentMethodTypes: SimpleBuyPaymentMethodTypesServiceAPI!
    var paymentMethodTypes: SimpleBuyPaymentMethodTypesServiceAPI {
        underlyingPaymentMethodTypes
    }
}

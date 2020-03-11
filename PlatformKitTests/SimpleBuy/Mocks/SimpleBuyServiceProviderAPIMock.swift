//
//  SimpleBuyServiceProviderAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class SimpleBuyServiceProviderAPIMock: SimpleBuyServiceProviderAPI {
    
    var cache: SimpleBuyEventCache = .init(cacheSuite: UserDefaults.standard)
    
    var underlyingRepository: DataRepositoryAPI!
    var dataRepository: DataRepositoryAPI {
        return underlyingRepository
    }
    
    var underlyingSupportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI!
    var supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI {
        underlyingSupportedPairsInteractor
    }
    
    var underlyingSupportedPairs: SimpleBuySupportedPairsServiceAPI!
    var supportedPairs: SimpleBuySupportedPairsServiceAPI {
        return underlyingSupportedPairs
    }

    var underlyingSuggestedAmounts: SimpleBuySuggestedAmountsServiceAPI!
    var suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI {
        return underlyingSuggestedAmounts
    }

    var underlyingOrdersDetails: SimpleBuyOrdersServiceAPI!
    var ordersDetails: SimpleBuyOrdersServiceAPI {
        return underlyingOrdersDetails
    }

    var underlyingSettings: (FiatCurrencySettingsServiceAPI & SettingsServiceAPI)!
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI {
        return underlyingSettings
    }

    var underlyingFlowAvailability: SimpleBuyFlowAvailabilityServiceAPI!
    var flowAvailability: SimpleBuyFlowAvailabilityServiceAPI {
        return underlyingFlowAvailability
    }

    var underlyingAvailability: SimpleBuyAvailabilityServiceAPI!
    var availability: SimpleBuyAvailabilityServiceAPI {
        underlyingAvailability
    }
    
    var underlyingEligibility: SimpleBuyEligibilityServiceAPI!
    var eligibility: SimpleBuyEligibilityServiceAPI {
        return underlyingEligibility
    }

    var underlyingOrderCreation: SimpleBuyOrderCreationServiceAPI!
    var orderCreation: SimpleBuyOrderCreationServiceAPI {
        return underlyingOrderCreation
    }

    var underlyingPaymentAccount: SimpleBuyPaymentAccountServiceAPI!
    var paymentAccount: SimpleBuyPaymentAccountServiceAPI {
        return underlyingPaymentAccount
    }

    var underlyingOrderQuote: SimpleBuyOrderQuoteServiceAPI!
    var orderQuote: SimpleBuyOrderQuoteServiceAPI {
        return underlyingOrderQuote
    }
    
    var underlyingPendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI!
    var pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI {
        return underlyingPendingOrderDetails
    }
    
    var underlyingoOrderCancellation: SimpleBuyOrderCancellationServiceAPI!
    var orderCancellation: SimpleBuyOrderCancellationServiceAPI {
        return underlyingoOrderCancellation
    }
}

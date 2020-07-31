//
//  ServiceProviderAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BuySellKit
@testable import PlatformKit
import RxSwift
@testable import ToolKit

final class ServiceProviderAPIMock: ServiceProviderAPI {
    
    var underlyingOrderCompletion: PendingOrderCompletionServiceAPI!
    var orderCompletion: PendingOrderCompletionServiceAPI {
        underlyingOrderCompletion
    }
    
    var underlyingOrderConfirmation: OrderConfirmationServiceAPI!
    var orderConfirmation: OrderConfirmationServiceAPI {
        underlyingOrderConfirmation
    }
    
    var cache: EventCache = .init(cacheSuite: MemoryCacheSuite())
    
    var underlyingPendingOrderCreation: PendingOrderCreationServiceAPI!
    func orderCreation(for paymentMethod: PaymentMethod.MethodType) -> PendingOrderCreationServiceAPI {
        underlyingPendingOrderCreation
    }
    
    var underlyingRepository: DataRepositoryAPI!
    var dataRepository: DataRepositoryAPI {
        underlyingRepository
    }
    
    var underlyingSupportedPairsInteractor: SupportedPairsInteractorServiceAPI!
    var supportedPairsInteractor: SupportedPairsInteractorServiceAPI {
        underlyingSupportedPairsInteractor
    }
    
    var underlyingSupportedPairs: SupportedPairsServiceAPI!
    var supportedPairs: SupportedPairsServiceAPI {
        underlyingSupportedPairs
    }

    var underlyingSuggestedAmounts: SuggestedAmountsServiceAPI!
    var suggestedAmounts: SuggestedAmountsServiceAPI {
        underlyingSuggestedAmounts
    }

    var underlyingOrdersDetails: OrdersServiceAPI!
    var ordersDetails: OrdersServiceAPI {
        underlyingOrdersDetails
    }
    
    var underlyingBeneficiaries: BeneficiariesServiceAPI!
    var beneficiaries: BeneficiariesServiceAPI {
        underlyingBeneficiaries
    }

    var underlyingBeneficiariesDeletion: PaymentMethodDeletionServiceAPI!
    var beneficiariesDeletion: PaymentMethodDeletionServiceAPI {
        underlyingBeneficiariesDeletion
    }
    
    var underlyingSettings: (FiatCurrencySettingsServiceAPI & SettingsServiceAPI)!
    var settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI {
        underlyingSettings
    }

    var underlyingSupportedCurrencies: SupportedCurrenciesServiceAPI!
    var supportedCurrencies: SupportedCurrenciesServiceAPI {
        underlyingSupportedCurrencies
    }
    
    var underlyingEligibility: EligibilityServiceAPI!
    var eligibility: EligibilityServiceAPI {
        underlyingEligibility
    }

    var underlyingOrderCreation: OrderCreationServiceAPI!
    var orderCreation: OrderCreationServiceAPI {
        underlyingOrderCreation
    }

    var underlyingPaymentAccount: PaymentAccountServiceAPI!
    var paymentAccount: PaymentAccountServiceAPI {
        underlyingPaymentAccount
    }

    var underlyingOrderQuote: OrderQuoteServiceAPI!
    var orderQuote: OrderQuoteServiceAPI {
        underlyingOrderQuote
    }
    
    var underlyingPendingOrderDetails: PendingOrderDetailsServiceAPI!
    var pendingOrderDetails: PendingOrderDetailsServiceAPI {
        underlyingPendingOrderDetails
    }
    
    var underlyingoOrderCancellation: OrderCancellationServiceAPI!
    var orderCancellation: OrderCancellationServiceAPI {
        underlyingoOrderCancellation
    }
    
    var underlyingPaymentMethods: PaymentMethodsServiceAPI!
    var paymentMethods: PaymentMethodsServiceAPI {
        underlyingPaymentMethods
    }
    
    var underlyingPaymentMethodTypes: PaymentMethodTypesServiceAPI!
    var paymentMethodTypes: PaymentMethodTypesServiceAPI {
        underlyingPaymentMethodTypes
    }
}

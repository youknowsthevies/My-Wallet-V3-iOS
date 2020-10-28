//
//  DIKit.swift
//  BuySellKit
//
//  Created by Jack Pooley on 25/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import ToolKit

extension DependencyContainer {
    
    // MARK: - BuySellKit Module
     
    public static var buySellKit = module {
        
        // MARK: - Clients - General
        
        factory { APIClient() as SimpleBuyClientAPI }

        factory { () -> PaymentMethodsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as PaymentMethodsClientAPI
        }
        
        factory { () -> SupportedPairsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as SupportedPairsClientAPI
        }
        
        factory { () -> BeneficiariesClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as BeneficiariesClientAPI
        }
        
        factory { () -> OrderDetailsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderDetailsClientAPI
        }
        
        factory { () -> OrderCancellationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderCancellationClientAPI
        }
        
        factory { () -> OrderCreationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderCreationClientAPI
        }
        
        factory { () -> EligibilityClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as EligibilityClientAPI
        }
        
        factory { () -> PaymentAccountClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as PaymentAccountClientAPI
        }

        factory { () -> SuggestedAmountsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as SuggestedAmountsClientAPI
        }

        factory { () -> QuoteClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client
        }

        factory { () -> CardOrderConfirmationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client
        }

        factory { () -> WithdrawalClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as WithdrawalClientAPI
        }

        factory { WithdrawalService() as WithdrawalServiceAPI }
        
        // MARK: - Clients - Cards
        
        factory { CardClient() as CardClientAPI }
        
        factory { EveryPayClient() as EveryPayClientAPI }

        factory { () -> CardListClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardListClientAPI
        }

        // MARK: - Services - General

        factory { OrderConfirmationService() as OrderConfirmationServiceAPI }

        factory { OrderQuoteService() as OrderQuoteServiceAPI }
        
        factory { EventCache() }
        
        single { OrdersService() as OrdersServiceAPI }
        
        factory { OrdersFiatActivityItemEventService() as FiatActivityItemEventFetcherAPI }
        
        factory { OrdersActivityEventService() as OrdersActivityEventServiceAPI }
        
        factory { PendingOrderDetailsService() as PendingOrderDetailsServiceAPI }
        
        factory { OrderCancellationService() as OrderCancellationServiceAPI }
        
        factory { OrderCreationService() as OrderCreationServiceAPI }
        
        single { PaymentMethodsService() as PaymentMethodsServiceAPI }
        
        factory { PaymentAccountService() as PaymentAccountServiceAPI }
        
        single { SupportedPairsInteractorService() as SupportedPairsInteractorServiceAPI }
        
        factory { SupportedPairsService() as SupportedPairsServiceAPI }
        
        single { BeneficiariesService() as BeneficiariesServiceAPI }
        
        factory { PaymentMethodTypesService() as PaymentMethodTypesServiceAPI }
        
        single { EligibilityService() as EligibilityServiceAPI }
        
        factory { SuggestedAmountsService() as SuggestedAmountsServiceAPI }

        // MARK: - Services - Cards
        
        single { CardListService() as CardListServiceAPI }
    }
}

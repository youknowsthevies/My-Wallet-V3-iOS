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

        factory { () -> PaymentEligibleMethodsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as PaymentEligibleMethodsClientAPI
        }

        factory { () -> LinkedBanksClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as LinkedBanksClientAPI
        }

        factory { WithdrawalService() as WithdrawalServiceAPI }
        
        // MARK: - Clients - Cards
        
        factory { CardClient() as CardClientAPI }
        
        factory { EveryPayClient() as EveryPayClientAPI }

        factory { () -> CardListClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardListClientAPI
        }
        
        factory { () -> CardDeletionClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDeletionClientAPI
        }
        
        factory { () -> CardDetailClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDetailClientAPI
        }

        // MARK: - Services - General
        
        factory { OrderConfirmationService() as OrderConfirmationServiceAPI }

        factory { OrderQuoteService() as OrderQuoteServiceAPI }
        
        factory { EventCache() }
        
        single { OrdersService() as OrdersServiceAPI }
        
        factory { OrdersFiatActivityItemEventService() as FiatActivityItemEventFetcherAPI }
        
        factory { OrdersActivityEventService() as OrdersActivityEventServiceAPI }
        
        factory { PendingOrderDetailsService() as PendingOrderDetailsServiceAPI }

        factory { PendingOrderCompletionService() as PendingOrderCompletionServiceAPI }
        
        factory { OrderCancellationService() as OrderCancellationServiceAPI }
        
        factory { OrderCreationService() as OrderCreationServiceAPI }

        factory { PaymentAccountService() as PaymentAccountServiceAPI }

        single { SupportedPairsInteractorService() as SupportedPairsInteractorServiceAPI }
        
        factory { SupportedPairsService() as SupportedPairsServiceAPI }

        single { EligibilityService() as EligibilityServiceAPI }
        
        factory { SuggestedAmountsService() as SuggestedAmountsServiceAPI }

        factory { LinkedBanksService() as LinkedBanksServiceAPI }

        // MARK: - Services - Payment Methods

        single { BeneficiariesService() as BeneficiariesServiceAPI }

        single { PaymentMethodTypesService() as PaymentMethodTypesServiceAPI }

        single { () -> PaymentMethodsServiceAPI in
            let internalFeatureService: InternalFeatureFlagServiceAPI = DIKit.resolve()
            if internalFeatureService.isEnabled(.achFlow) {
                return EligiblePaymentMethodsService() as PaymentMethodsServiceAPI
            }
            return PaymentMethodsService() as PaymentMethodsServiceAPI
        }

        // MARK: - Services - Cards

        factory { CardActivationService() as CardActivationServiceAPI }

        factory { CardUpdateService() as CardUpdateServiceAPI }

        single { CardListService() as CardListServiceAPI }
        
        factory { CardDeletionService() as PaymentMethodDeletionServiceAPI }

        // MARK: - Services - Linked Banks

        factory { LinkedBankActivationService() as LinkedBankActivationServiceAPI }
    }
}

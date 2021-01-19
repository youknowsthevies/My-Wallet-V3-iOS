//
//  DIKit.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    public static var transactionKit = module {

        factory { () -> OrderCreationClientAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as OrderCreationClientAPI
        }

        factory { () -> OrderUpdateClientAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as OrderUpdateClientAPI
        }

        factory { () -> CustodialQuoteAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as CustodialQuoteAPI
        }
        
        factory { () -> OrderTransactionLimitsClientAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as OrderTransactionLimitsClientAPI
        }
        
        factory { () -> AvailablePairsClientAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as AvailablePairsClientAPI
        }
        
        factory { () -> OrderFetchingClientAPI in
            let client: TransactionKitClientAPI = DIKit.resolve()
            return client as OrderFetchingClientAPI
        }
        
        factory { APIClient() as TransactionKitClientAPI }
        
        factory { OrderQuoteService() as OrderQuoteServiceAPI }
        
        factory { AvailableTradingPairsService() as AvailableTradingPairsServiceAPI }

        factory { OrderCreationService() as OrderCreationServiceAPI }

        factory { OrderUpdateService() as OrderUpdateServiceAPI }
        
        factory { OrderFetchingService() as OrderFetchingServiceAPI }
        
        factory { TransactionLimitsService() as TransactionLimitsServiceAPI }
        
        factory { PendingSwapCompletionService() as PendingSwapCompletionServiceAPI }
    }
}

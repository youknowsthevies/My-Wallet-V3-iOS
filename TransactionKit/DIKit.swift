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
        
        factory { APIClient() as TransactionKitClientAPI }
        
        single { OrderQuoteService() as OrderQuoteServiceAPI }
    }
}

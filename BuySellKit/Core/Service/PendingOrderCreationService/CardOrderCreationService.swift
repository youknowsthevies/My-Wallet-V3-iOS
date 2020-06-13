//
//  CardOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

final class CardOrderCreationService: SimpleBuyPendingOrderCreationServiceAPI {
    
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI
    
    init(orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
         orderCreationService: SimpleBuyOrderCreationServiceAPI) {
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    func create(using checkoutData: CheckoutData) -> Single<PendingConfirmationCheckoutData> {
        let quote = orderQuoteService.getQuote(
            for: .buy,
            using: checkoutData
        )
        
        let creation = orderCreationService.create(
            using: checkoutData
        )
        
        return Single
            .zip(quote, creation)
            .map { (quote, checkoutData) in
                PendingConfirmationCheckoutData(quote: quote, checkoutData: checkoutData)
            }
    }
}

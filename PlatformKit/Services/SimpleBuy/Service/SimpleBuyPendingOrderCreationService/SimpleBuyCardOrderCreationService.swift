//
//  SimpleBuyCardOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyCardOrderCreationService: SimpleBuyPendingOrderCreationServiceAPI {
    
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI
    
    public init(orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
                orderCreationService: SimpleBuyOrderCreationServiceAPI) {
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    public func create(using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyPendingConfirmationCheckoutData> {
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
                SimpleBuyPendingConfirmationCheckoutData(quote: quote, checkoutData: checkoutData)
            }
    }
}

//
//  CardOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

final class CardOrderCreationService: PendingOrderCreationServiceAPI {
    
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI
    
    init(orderQuoteService: OrderQuoteServiceAPI,
         orderCreationService: OrderCreationServiceAPI) {
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<PendingConfirmationCheckoutData> {
        let quote = orderQuoteService.getQuote(
            for: .buy,
            cryptoCurrency: candidateOrderDetails.cryptoCurrency,
            fiatValue: candidateOrderDetails.fiatValue
        )
        let creation = orderCreationService.create(using: candidateOrderDetails)
        return Single
            .zip(quote, creation)
            .map { (quote, checkoutData) in
                PendingConfirmationCheckoutData(quote: quote, checkoutData: checkoutData)
            }
    }
}

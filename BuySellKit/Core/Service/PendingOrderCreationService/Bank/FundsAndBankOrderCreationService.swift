//
//  FundsAndBankOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

final class FundsAndBankOrderCreationService: PendingOrderCreationServiceAPI {
    
    private let paymentAccountService: PaymentAccountServiceAPI
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI

    init(paymentAccountService: PaymentAccountServiceAPI,
         orderQuoteService: OrderQuoteServiceAPI,
         orderCreationService: OrderCreationServiceAPI) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<PendingConfirmationCheckoutData> {
        let quote = orderQuoteService
            .getQuote(
                for: .buy,
                cryptoCurrency: candidateOrderDetails.cryptoCurrency,
                fiatValue: candidateOrderDetails.fiatValue
            )
        
        let paymentAccount = paymentAccountService
            .paymentAccount(for: candidateOrderDetails.fiatValue.currencyType)
        
        return Single
            .zip(quote, paymentAccount)
            .map { (quote: $0.0, account: $0.1) }
            .flatMap(weak: self) { (self, payload) in
                self.orderCreationService.create(using: candidateOrderDetails)
                    .map { checkoutData in
                        PendingConfirmationCheckoutData(
                            quote: payload.quote,
                            checkoutData: checkoutData.checkoutData(byAppending: payload.account)
                        )
                    }
            }
    }
}

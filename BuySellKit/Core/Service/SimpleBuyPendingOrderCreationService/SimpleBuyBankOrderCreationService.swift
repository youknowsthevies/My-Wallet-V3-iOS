//
//  SimpleBuyBankOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyBankOrderCreationService: SimpleBuyPendingOrderCreationServiceAPI {
    
    private let paymentAccountService: SimpleBuyPaymentAccountServiceAPI
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI

    public init(paymentAccountService: SimpleBuyPaymentAccountServiceAPI,
                orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
                orderCreationService: SimpleBuyOrderCreationServiceAPI) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    public func create(using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyPendingConfirmationCheckoutData> {
        paymentAccountService
            .paymentAccount(for: checkoutData.fiatValue.currency)
            .map { account -> SimpleBuyCheckoutData in
                checkoutData.checkoutData(byAppending: account)
            }
            .flatMap(weak: self) { (self, checkoutData) -> Single<SimpleBuyPendingConfirmationCheckoutData> in
                self.orderQuoteService
                    .getQuote(
                        for: .buy,
                        using: checkoutData
                    )
                    .map { quote -> SimpleBuyPendingConfirmationCheckoutData in
                        .init(quote: quote, checkoutData: checkoutData)
                    }
            }
            .flatMap(weak: self) { (self, data) in
                self.orderCreationService
                    .create(
                        using: data.checkoutData
                    )
                    .map { checkoutData in
                        data.data(byAppending: checkoutData)
                    }
            }
    }
}

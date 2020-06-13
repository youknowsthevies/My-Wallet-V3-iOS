//
//  OrderQuoteService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

protocol SimpleBuyOrderQuoteServiceAPI: class {
    func getQuote(for action: Order.Action,
                  using checkoutData: CheckoutData) -> Single<SimpleBuyQuote>
}

final class OrderQuoteService: SimpleBuyOrderQuoteServiceAPI {
    
    // MARK: - Properties
    
    private let client: QuoteClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    init(client: QuoteClientAPI,
         authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    public func getQuote(for action: Order.Action,
                         using checkoutData: CheckoutData) -> Single<SimpleBuyQuote> {
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<QuoteResponse> in
                self.client.getQuote(
                    for: action,
                    to: checkoutData.cryptoCurrency,
                    amount: checkoutData.fiatValue,
                    token: token)
            }
            .map {
                try SimpleBuyQuote(
                    to: checkoutData.cryptoCurrency,
                    amount: checkoutData.fiatValue,
                    response: $0
                )
            }
    }
}

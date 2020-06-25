//
//  OrderQuoteService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol OrderQuoteServiceAPI: class {
    func getQuote(for action: Order.Action,
                  cryptoCurrency: CryptoCurrency,
                  fiatValue: FiatValue) -> Single<Quote>
}

final class OrderQuoteService: OrderQuoteServiceAPI {
    
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
    
    func getQuote(for action: Order.Action,
                  cryptoCurrency: CryptoCurrency,
                  fiatValue: FiatValue) -> Single<Quote> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<QuoteResponse> in
                self.client.getQuote(
                    for: action,
                    to: cryptoCurrency,
                    amount: fiatValue,
                    token: token)
            }
            .map {
                try Quote(
                    to: cryptoCurrency,
                    amount: fiatValue,
                    response: $0
                )
            }
    }
}

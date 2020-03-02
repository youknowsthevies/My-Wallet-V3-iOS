//
//  SimpleBuyOrderQuoteService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyOrderQuoteService: SimpleBuyOrderQuoteServiceAPI {
    
    // MARK: - Properties
    
    private let client: SimpleBuyQuoteClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    public init(client: SimpleBuyQuoteClientAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    public func getQuote(for action: SimpleBuyOrder.Action,
                         using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyQuote> {
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<SimpleBuyQuoteResponse> in
                self.client.getQuote(
                    for: action,
                    to: checkoutData.cryptoCurrency,
                    amount: checkoutData.fiatValue,
                    token: token)
            }
            .map {
                try SimpleBuyQuote(response: $0)
            }
    }
}

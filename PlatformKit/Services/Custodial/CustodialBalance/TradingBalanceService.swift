//
//  TradingBalanceService.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol TradingBalanceServiceAPI: AnyObject {
    func balance(for crypto: CryptoCurrency) -> Single<TradingAccountBalanceState>
}

public class TradingBalanceService: TradingBalanceServiceAPI {

    // MARK: - Private Properties

    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: TradingBalanceClientAPI

    // MARK: - Setup

    public init(client: TradingBalanceClientAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
    }

    // MARK: - Public Methods

    public func balance(for crypto: CryptoCurrency) -> Single<TradingAccountBalanceState> {
        authenticationService.tokenString
            .flatMap(weak: self) { (self, token: String) in
                self.balance(for: crypto, with: token)
            }
            .catchErrorJustReturn(.absent)
    }
    
    private func balance(for currency: CryptoCurrency,
                         with token: String) -> Single<TradingAccountBalanceState> {
        client
            .balance(for: currency.code, token: token)
            .map { response -> TradingAccountBalanceState in
                guard let response = response else {
                    return .absent
                }
                guard let balance = response[currency] else {
                    return .absent
                }
                return .present(
                    TradingAccountBalance(
                        currency: currency,
                        response: balance
                    )
                )
            }
    }
}

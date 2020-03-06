//
//  CustodialBalanceService.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public class CustodialBalanceService: CustodialBalanceServiceAPI {

    // MARK: - Private Properties

    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: CustodialBalanceClientAPI

    // MARK: - Setup

    public init(client: CustodialBalanceClientAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
    }

    // MARK: - Public Methods

    public func balance(for crypto: CryptoCurrency) -> Single<CustodialBalanceState> {
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token: String) -> Single<CustodialBalanceState> in
                self.balance(for: crypto, with: token)
            }
            .catchErrorJustReturn(.absent)
    }
    
    private func balance(for crypto: CryptoCurrency, with token: String) -> Single<CustodialBalanceState> {
        return client
            .balance(with: token)
            .map { response -> CustodialBalanceState in
                guard let response = response[crypto] else { return .absent }
                return .present(CustodialBalance(currency: crypto, response: response))
            }
    }
}

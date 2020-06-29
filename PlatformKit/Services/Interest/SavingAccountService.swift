//
//  InterestAccountService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol SavingAccountServiceAPI: AnyObject {
    func balance(for currency: CryptoCurrency) -> Single<SavingsAccountBalanceState>
    func rate(for currency: CryptoCurrency) -> Single<Double>
}

public class SavingAccountService: SavingAccountServiceAPI {

    // MARK: - Private Properties

    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: SavingsAccountClientAPI
    private let featureFetching: FeatureFetching
    private let cachedSavingsAccountBalance: CachedValue<SavingsAccountBalanceResponse>

    // MARK: - Setup

    public init(client: SavingsAccountClientAPI = SavingsAccountClient(),
                authenticationService: NabuAuthenticationServiceAPI,
                featureFetching: FeatureFetching) {
        self.client = client
        self.authenticationService = authenticationService
        self.featureFetching = featureFetching
        self.cachedSavingsAccountBalance = CachedValue<SavingsAccountBalanceResponse>(configuration: .periodicAndLogin(10))
        cachedSavingsAccountBalance.setFetch(weak: self) { (self) in
            self.fetchBalances()
        }
    }

    // MARK: - Public Methods

    public func balance(for currency: CryptoCurrency) -> Single<SavingsAccountBalanceState> {
        cachedSavingsAccountBalance
            .valueSingle
            .map { $0[currency] }
            .map { response in
                guard let response = response,
                    let accountBalance = SavingsAccountBalance(currency: currency, response: response) else {
                        return .absent
                }
                return .present(accountBalance)
            }
    }

    private func fetchBalances() -> Single<SavingsAccountBalanceResponse> {
        featureFetching
            .fetchBool(for: .interestAccountEnabled)
            .flatMap(weak: self) { (self, _) in
                self.authenticationService
                    .tokenString
                    .flatMap(weak: self) { (self, token) in
                        self.client.balance(token: token).map { balance in
                            guard let balance = balance else {
                                return .empty
                            }
                            return balance
                        }
                    }
            }
            .catchErrorJustReturn(.empty)
    }

    public func rate(for currency: CryptoCurrency) -> Single<Double> {
        authenticationService.tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.rate(for: currency.rawValue, token: token)
            }
            .map { $0.rate }
    }
}

//
//  InterestAccountService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

class SavingAccountService: SavingAccountServiceAPI {
    
    // MARK: - Public Properties
    
    var balances: Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.valueSingle
    }

    // MARK: - Private Properties
    
    private let client: SavingsAccountClientAPI
    private let custodialFeatureFetcher: CustodialFeatureFetching
    private let cachedValue: CachedValue<CustodialAccountBalanceStates>

    private lazy var setup: Void = {
        cachedValue.setFetch(weak: self) { (self) in
            self.fetchBalancesResponse()
                .map { CustodialAccountBalanceStates(response: $0) }
        }
    }()
    
    // MARK: - Setup

    init(client: SavingsAccountClientAPI = resolve(),
         custodialFeatureFetcher: CustodialFeatureFetching = resolve()) {
        self.client = client
        self.custodialFeatureFetcher = custodialFeatureFetcher
        self.cachedValue = CachedValue(configuration: .onSubscription())
    }

    // MARK: - Public Methods

    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState> {
        balances.map { $0[currency.currency] }
    }

    private func fetchBalancesResponse() -> Single<SavingsAccountBalanceResponse> {
        custodialFeatureFetcher
            .featureEnabled(for: .interestAccountEnabled)
            .flatMap(weak: self) { (self, interestAccountEnabled) in
                guard interestAccountEnabled else {
                    return Single.just(.empty)
                }
                return self.client.balance.map { balance in
                    guard let balance = balance else {
                        return .empty
                    }
                    return balance
                }
            }
            .catchErrorJustReturn(.empty)
    }

    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.fetchValue
    }
    
    func rate(for currency: CryptoCurrency) -> Single<Double> {
        client.rate(for: currency.rawValue)
            .map { $0.rate }
    }
}

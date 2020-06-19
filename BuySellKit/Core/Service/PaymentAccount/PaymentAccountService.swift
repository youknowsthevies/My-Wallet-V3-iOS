//
//  PaymentAccountService.swift
//  PlatformKit
//
//  Created by Paulo on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

public protocol PaymentAccountServiceAPI: class {

    /// Fetch the Payment Account information for thr currency wallet's fiat currency
    var paymentAccount: Single<PaymentAccount> { get }
    
    /// Fetch the Payment Account information for the given currency.
    func paymentAccount(for currency: FiatCurrency) -> Single<PaymentAccount>
}

final class PaymentAccountService: PaymentAccountServiceAPI {

    // MARK: - Types

    private enum ServiceError: Error {
        case invalidResponse
    }
    
    // MARK: - Public Properties
    
    /// Using a currency service, get the currency currency and check if the user has a
    /// payment account for the currenctly set fiat currency
    var paymentAccount: Single<PaymentAccount> {
        fiatCurrencyService.fiatCurrency
            .flatMap(weak: self) { (self, currency) in
                self.paymentAccount(for: currency)
            }
    }
    
    // MARK: - Private Properties

    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: PaymentAccountClientAPI
    private let dataRepository: DataRepositoryAPI
    private let patcher: PaymentAccountPatcher

    // MARK: - Setup

    init(client: PaymentAccountClientAPI,
         dataRepository: DataRepositoryAPI,
         authenticationService: NabuAuthenticationServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         patcher: PaymentAccountPatcher = PaymentAccountPatcher()) {
        self.client = client
        self.authenticationService = authenticationService
        self.fiatCurrencyService = fiatCurrencyService
        self.dataRepository = dataRepository
        self.patcher = patcher
    }
    
    // MARK: - Public Methods

    func paymentAccount(for currency: FiatCurrency) -> Single<PaymentAccount> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<PaymentAccount> in
                self.fetchPaymentAccount(for: currency, with: token, patcher: self.patcher)
            }
    }

    // MARK: - Private Methods

    func fetchPaymentAccount(for currency: FiatCurrency,
                             with token: String,
                             patcher: PaymentAccountPatcher) -> Single<PaymentAccount> {
        Single
            .zip(
                client.paymentAccount(for: currency, token: token),
                dataRepository.user.take(1).asSingle()
            )
            .map { (response, user) -> PaymentAccount? in
                PaymentAccountBuilder
                    .build(response: response)
                    .map { patcher.patch($0, recipientName: user.personalDetails.fullName) }
            }
            .map { (account) -> PaymentAccount in
                guard let account = account else {
                    throw ServiceError.invalidResponse
                }
                return account
            }
    }
}

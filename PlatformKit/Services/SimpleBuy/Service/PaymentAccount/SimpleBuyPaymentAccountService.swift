//
//  SimpleBuyPaymentAccountService.swift
//  PlatformKit
//
//  Created by Paulo on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyPaymentAccountService: SimpleBuyPaymentAccountServiceAPI {

    // MARK: - Types

    private enum ServiceError: Error {
        case invalidResponse
    }
    
    // MARK: - Public Properties
    
    /// Using a currency service, get the currency currency and check if the user has a
    /// payment account for the currenctly set fiat currency
    public var paymentAccount: Single<SimpleBuyPaymentAccount> {
        fiatCurrencyService.fiatCurrency
            .flatMap(weak: self) { (self, currency) in
                self.paymentAccount(for: currency)
            }
    }
    
    // MARK: - Private Properties

    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: SimpleBuyPaymentAccountClientAPI
    private let dataRepository: DataRepositoryAPI
    private let patcher: SimpleBuyPaymentAccountPatcher

    // MARK: - Setup

    init(client: SimpleBuyPaymentAccountClientAPI,
         dataRepository: DataRepositoryAPI,
         authenticationService: NabuAuthenticationServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         patcher: SimpleBuyPaymentAccountPatcher) {
        self.client = client
        self.authenticationService = authenticationService
        self.fiatCurrencyService = fiatCurrencyService
        self.dataRepository = dataRepository
        self.patcher = patcher
    }

    public convenience init(client: SimpleBuyPaymentAccountClientAPI = SimpleBuyClient(),
                            dataRepository: DataRepositoryAPI,
                            authenticationService: NabuAuthenticationServiceAPI,
                            fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        self.init(client: client,
                  dataRepository: dataRepository,
                  authenticationService: authenticationService,
                  fiatCurrencyService: fiatCurrencyService,
                  patcher: SimpleBuyPaymentAccountPatcher())
    }
    
    // MARK: - Public Methods

    public func paymentAccount(for currency: FiatCurrency) -> Single<SimpleBuyPaymentAccount> {
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) -> Single<SimpleBuyPaymentAccount> in
                self.fetchPaymentAccount(for: currency, with: token, patcher: self.patcher)
            }
    }

    // MARK: - Private Methods

    private func fetchPaymentAccount(for currency: FiatCurrency,
                                     with token: String,
                                     patcher: SimpleBuyPaymentAccountPatcher) -> Single<SimpleBuyPaymentAccount> {
        return Single
            .zip(
                client.paymentAccount(for: currency, token: token),
                dataRepository.user.take(1).asSingle()
            )
            .map { (response, user) -> SimpleBuyPaymentAccount? in
                return SimpleBuyPaymentAccountBuilder
                    .build(response: response)
                    .map { patcher.patch($0, recipientName: user.personalDetails.fullName) }
            }
            .map { (account) -> SimpleBuyPaymentAccount in
                guard let account = account else {
                    throw ServiceError.invalidResponse
                }
                return account
            }
    }
}

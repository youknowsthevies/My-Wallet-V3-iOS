//
//  SimpleBuyPaymentMethodsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public final class SimpleBuyPaymentMethodsService: SimpleBuyPaymentMethodsServiceAPI {
    
    // MARK: - Public properties
        
    public var paymentMethods: Observable<[SimpleBuyPaymentMethod]> {
        cachedValue.valueObservable
    }
    
    public var paymentMethodsSingle: Single<[SimpleBuyPaymentMethod]> {
        cachedValue.valueSingle
    }
    
    public var supportedCardTypes: Single<Set<CardType>> {
        cachedValue.valueSingle.map { paymentMethods in
            guard let card = paymentMethods.first(where: { $0.type.isCard }) else {
                return []
            }
            switch card.type {
            case .card(let types):
                return types
            case .bankTransfer:
                return []
            }
        }
    }
        
    // MARK: - Private properties
    
    private let cachedValue: CachedValue<[SimpleBuyPaymentMethod]>
    
    // MARK: - Setup
    
    public init(client: SimpleBuyPaymentMethodsClientAPI,
                tiersService: KYCTiersServiceAPI,
                reactiveWallet: ReactiveWalletAPI,
                featureFetcher: FeatureFetching,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        
        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-payment-methods",
                refreshType: .onSubscription,
                fetchPriority: .fetchAll,
                flushNotificationName: .logout
            )
        )
        
        cachedValue
            .setFetch { () -> Observable<[SimpleBuyPaymentMethod]> in
                fiatCurrencyService.fiatCurrencyObservable
                    .flatMap { currency in
                        authenticationService
                            .tokenString
                            .asObservable()
                            .map { (token: $0, currency: currency) }
                    }
                    .flatMap { payload in
                        tiersService.fetchTiers()
                            .map { $0.isTier2Approved }
                            .flatMap { isTier2Approved in
                                client.paymentMethods(
                                    for: payload.currency.code,
                                    checkEligibility: isTier2Approved,
                                    token: payload.token
                                )
                            }
                            .asObservable()
                    }
                    .map { Array<SimpleBuyPaymentMethod>.init(response: $0) }
                    .map {
                        $0.filter {
                            switch $0.type {
                            case .card:
                                return true
                            case .bankTransfer:
                                // Filter out bank transfer details from currencies we do not
                                //  have local support/UI.
                                return SimpleBuyBankLocallySupportedCurrencies
                                    .fiatCurrencies
                                    .contains($0.min.currency)
                            }
                        }
                    }
                    .flatMap { methods -> Observable<[SimpleBuyPaymentMethod]> in
                        featureFetcher.fetchBool(for: .simpleBuyCardsEnabled)
                            .map { isEnabled in
                                guard !isEnabled else { return methods }
                                return methods.filter { !$0.type.isCard }
                            }
                            .asObservable()
                    }
            }
    }
    
    public func fetch() -> Observable<[SimpleBuyPaymentMethod]> {
        cachedValue.fetchValueObservable
    }
}

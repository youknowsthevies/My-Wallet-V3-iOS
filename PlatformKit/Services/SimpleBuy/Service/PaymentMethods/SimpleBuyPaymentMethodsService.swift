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
        
    // MARK: - Private properties
    
    private let cachedValue: CachedValue<[SimpleBuyPaymentMethod]>
    
    // MARK: - Setup
    
    public init(client: SimpleBuyPaymentMethodsClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI) {
        
        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-payment-methods",
                refreshType: .onSubscription,
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )
        
        cachedValue
            .setFetch { () -> Observable<[SimpleBuyPaymentMethod]> in
                return reactiveWallet.waitUntilInitializedSingle
                    .asObservable()
                    .flatMap {
                        Observable.combineLatest(
                            authenticationService.tokenString.asObservable(),
                            fiatCurrencyService.fiatCurrencyObservable
                        )
                        .map { (token: $0.0, currency: $0.1) }
                    }
                    .flatMap { payload in
                        client.paymentMethods(for: payload.currency.code, token: payload.token).asObservable()
                    }
                    .map { Array<SimpleBuyPaymentMethod>.init(response: $0) }
            }
    }
}

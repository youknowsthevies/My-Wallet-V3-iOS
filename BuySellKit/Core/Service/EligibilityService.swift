//
//  EligibilityService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

public protocol SimpleBuyEligibilityServiceAPI: class {

    /// Feature is enabled and SimpleBuyEligibilityClientAPI returns eligible for current fiat currency.
    var isEligible: Observable<Bool> { get }
    func fetch() -> Observable<Bool>
}

final class EligibilityService: SimpleBuyEligibilityServiceAPI {
    
    // MARK: - Properties
    
    public var isEligible: Observable<Bool> {
        isEligibleCachedValue.valueObservable
    }
    
    private let isEligibleCachedValue: CachedValue<Bool>
    
    // MARK: - Setup
    
    init(client: EligibilityClientAPI,
         reactiveWallet: ReactiveWalletAPI,
         authenticationService: NabuAuthenticationServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         featureFetcher: FeatureFetching) {
        
        isEligibleCachedValue = CachedValue(
            configuration: .init(
                identifier: "simple-buy-is-eligible",
                refreshType: .periodic(seconds: 2),
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )
        
        isEligibleCachedValue
            .setFetch { () -> Observable<Bool> in
                featureFetcher.fetchBool(for: .simpleBuyEnabled)
                    .asObservable()
                    .flatMap { isFeatureEnabled -> Observable<Bool> in
                        guard isFeatureEnabled else {
                            return .just(false)
                        }
                        return fiatCurrencyService.fiatCurrencyObservable
                            .flatMap { currency in
                                reactiveWallet.waitUntilInitializedSingle
                                    .asObservable()
                                    .flatMap { authenticationService.tokenString }
                                    .map { (token: $0, currency: currency) }
                            }
                            .flatMap { payload in
                                client.isEligible(
                                    for: payload.currency.code,
                                    methods: [
                                        PaymentMethod.MethodType.RawValue.bankTransfer,
                                        PaymentMethod.MethodType.RawValue.card
                                    ],
                                    token: payload.token
                                )
                            }
                            .map { $0.eligible }
                    }
        }
    }
    
    public func fetch() -> Observable<Bool> {
        isEligibleCachedValue.fetchValueObservable
    }
}

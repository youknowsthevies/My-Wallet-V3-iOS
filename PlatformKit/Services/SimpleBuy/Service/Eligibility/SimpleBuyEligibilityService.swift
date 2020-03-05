//
//  CanTradeService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class SimpleBuyEligibilityService: SimpleBuyEligibilityServiceAPI {
    
    // MARK: - Properties
    
    public var isEligible: Observable<Bool> {
        isEligibleCachedValue.valueObservable
    }
    
    private let isEligibleCachedValue = CachedValue<Bool>(configuration: .onSubscriptionAndLogin)
    
    // MARK: - Setup
    
    public init(client: SimpleBuyEligibilityClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI,
                featureFetcher: FeatureFetching) {
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
                                client.isEligible(for: payload.currency.code, token: payload.token)
                            }
                            .map { $0.eligible }
                    }
        }
    }
    
    public func fetch() -> Observable<Bool> {
        isEligibleCachedValue.fetchValueObservable
    }
}

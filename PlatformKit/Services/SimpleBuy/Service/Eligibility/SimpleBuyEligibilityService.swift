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
    
    public var isEligible: Single<Bool> {
        isEligibleCachedValue.valueSingle
    }
    
    private let isEligibleCachedValue = CachedValue<Bool>(refreshType: .onSubscription)
    
    // MARK: - Setup
    
    public init(client: SimpleBuyEligibilityClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI,
                featureFetcher: FeatureFetching) {
        isEligibleCachedValue
            .setFetch(weak: self) { (self) -> Single<Bool> in
                featureFetcher.fetchBool(for: .simpleBuyEnabled)
                    .flatMap { isFeatureEnabled -> Single<Bool> in
                        guard isFeatureEnabled else {
                            return .just(false)
                        }
                        // Get token
                        let token = reactiveWallet.waitUntilInitializedSingle
                            .flatMap { authenticationService.tokenString }
                        
                        // Get fiat currency
                        let fiatCurrency = fiatCurrencyService.fiatCurrency
                            
                        // Invoke client with topen and fiat currency
                        return Single
                            .zip(fiatCurrency, token)
                            .flatMap { (currency, token) in
                                client.isEligible(for: currency.code, token: token)
                            }
                            .map { $0.eligible }
                    }
        }
    }
}

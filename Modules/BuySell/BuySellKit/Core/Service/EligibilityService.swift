//
//  EligibilityService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class EligibilityService: EligibilityServiceAPI {
    
    // MARK: - Properties
    
    public var isEligible: Single<Bool> {
        isEligibileValue.valueSingle
    }
    
    private let isEligibileValue: CachedValue<Bool>
    private let client: EligibilityClientAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let featureFetcher: FeatureFetching
    
    // MARK: - Setup
    
    init(client: EligibilityClientAPI = resolve(),
         reactiveWallet: ReactiveWalletAPI = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
         featureFetcher: FeatureFetching  = resolve()) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.fiatCurrencyService = fiatCurrencyService
        self.featureFetcher = featureFetcher
        self.isEligibileValue = CachedValue(
            configuration: CachedValueConfiguration(
                refreshType: .periodic(seconds: TimeInterval(30)),
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )
        
        isEligibileValue.setFetch(weak: self) { (self) in
            self.reactiveWallet.waitUntilInitializedSingle
                .flatMap(weak: self) { (self, _) -> Single<Bool> in
                    self.featureFetcher.fetchBool(for: .simpleBuyEnabled)
                }
                .flatMap(weak: self) { (self, isFeatureEnabled) -> Single<Bool> in
                    guard isFeatureEnabled else {
                        return .just(false)
                    }
                    return self.fiatCurrencyService.fiatCurrency
                        .flatMap { currency -> Single<EligibilityResponse> in
                            self.client.isEligible(
                                for: currency.code,
                                methods: [
                                    PaymentMethodPayloadType.bankTransfer.rawValue,
                                    PaymentMethodPayloadType.card.rawValue
                                ]
                            )
                        }
                        .map(\.eligible)
                }
        }
    }

    func fetch() -> Single<Bool> {
        isEligibileValue.fetchValue
    }
}

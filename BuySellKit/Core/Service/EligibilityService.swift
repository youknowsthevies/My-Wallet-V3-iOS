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
    
    public var isEligible: Observable<Bool> {
        isEligibileRelay
            .flatMap(weak: self) { (self, isEligibile) -> Observable<Bool> in
                guard let isEligibile = isEligibile else {
                    return self.fetch()
                }
                return .just(isEligibile)
            }
            .distinctUntilChanged()
    }
    
    private let isEligibileRelay = BehaviorRelay<Bool?>(value: nil)
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
        
        NotificationCenter.when(.logout) { [weak isEligibileRelay] _ in
            isEligibileRelay?.accept(nil)
        }
    }
    
    func fetch() -> Observable<Bool> {
        featureFetcher
            .fetchBool(for: .simpleBuyEnabled)
            .asObservable()
            .flatMap(weak: self) { (self, isFeatureEnabled) -> Observable<Bool> in
                guard isFeatureEnabled else {
                    return .just(false)
                }
                return self.fiatCurrencyService.fiatCurrencyObservable
                    .flatMap { currency in
                        self.reactiveWallet.waitUntilInitializedSingle
                            .asObservable()
                            .map { currency }
                    }
                    .flatMap { currency in
                        self.client.isEligible(
                            for: currency.code,
                            methods: [
                                PaymentMethodPayloadType.bankTransfer.rawValue,
                                PaymentMethodPayloadType.card.rawValue
                            ]
                        )
                    }
                    .map { $0.eligible }
            }
            .do(onNext: { [weak self] isEligible in
                self?.isEligibileRelay.accept(isEligible)
            })
    }
}

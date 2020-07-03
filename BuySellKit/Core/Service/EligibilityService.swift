//
//  EligibilityService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import ToolKit

public protocol EligibilityServiceAPI: class {

    /// Feature is enabled and EligibilityClientAPI returns eligible for current fiat currency.
    var isEligible: Observable<Bool> { get }
    func fetch() -> Observable<Bool>
}

final class EligibilityService: EligibilityServiceAPI {
    
    // MARK: - Properties
    
    public var isEligible: Observable<Bool> {
        isEligibileRelay
            .flatMap(weak: self) { (self, isEligibile) -> Observable<Bool> in
                guard let isEligibile = isEligibile else {
                    return self.fetch().asObservable()
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
    
    init(client: EligibilityClientAPI,
         reactiveWallet: ReactiveWalletAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         featureFetcher: FeatureFetching) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.fiatCurrencyService = fiatCurrencyService
        self.featureFetcher = featureFetcher
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
                                PaymentMethod.MethodType.RawValue.bankTransfer,
                                PaymentMethod.MethodType.RawValue.card
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

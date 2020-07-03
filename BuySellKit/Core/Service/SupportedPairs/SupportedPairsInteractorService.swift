//
//  SupportedPairsInteractorService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// The calculation state of Simple Buy supported pairs
public typealias BuyCryptoSupportedPairsCalculationState = ValueCalculationState<SupportedPairs>

/// A Simple Buy Service that provides the supported pairs for the current Fiat Currency.
public protocol SupportedPairsInteractorServiceAPI: class {
    var pairs: Observable<SupportedPairs> { get }
    func fetch() -> Observable<SupportedPairs>
}

final class SupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {

    // MARK: - Public properties

    public var pairs: Observable<SupportedPairs> {
        pairsRelay
            .flatMap(weak: self) { (self, pairs) -> Observable<SupportedPairs> in
                guard let pairs = pairs else {
                    return self.fetch()
                }
                return .just(pairs)
            }
            .distinctUntilChanged()
    }
    
    // MARK: - Private properties
    
    private let pairsRelay = BehaviorRelay<SupportedPairs?>(value: nil)

    private let featureFetcher: FeatureFetching
    private let pairsService: SupportedPairsServiceAPI
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    
    // MARK: - Setup

    init(featureFetcher: FeatureFetching,
         pairsService: SupportedPairsServiceAPI,
         fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI) {
        self.featureFetcher = featureFetcher
        self.pairsService = pairsService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
    }

    func fetch() -> Observable<SupportedPairs> {
        featureFetcher.fetchBool(for: .simpleBuyEnabled)
            .asObservable()
            .flatMapLatest(weak: self) { (self, isFeatureEnabled) -> Observable<SupportedPairs> in
                guard isFeatureEnabled else {
                    return .just(.empty)
                }
                return self.fiatCurrencySettingsService
                    .fiatCurrencyObservable
                    .map { .only(fiatCurrency: $0) }
                    .flatMapLatest { self.pairsService.fetchPairs(for: $0).asObservable() }
            }
            .do(onNext: { [weak self] pairs in
                self?.pairsRelay.accept(pairs)
            })
            
    }
}

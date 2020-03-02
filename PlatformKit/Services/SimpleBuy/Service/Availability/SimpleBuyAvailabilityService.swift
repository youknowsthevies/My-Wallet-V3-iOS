//
//  SimpleBuyAvailabilityService.swift
//  Blockchain
//
//  Created by Jack on 24/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public final class SimpleBuyAvailabilityService: SimpleBuyAvailabilityServiceAPI {

    // MARK: - Types
        
    private enum Constant {
        static let supportedFiatCurrencies: [FiatCurrency] = [.GBP, .EUR]
    }
    
    // MARK: - Public properties
    
    public var valueObservable: Observable<Bool> {
        cachedValue.valueObservable
    }
    
    public var valueSingle: Single<Bool> {
        cachedValue.valueSingle
    }
    
    // MARK: - Private properties
    
    private let cachedValue = CachedValue<Bool>()
    private let pairsService: SimpleBuySupportedPairsInteractorServiceAPI
    private let featureFetcher: FeatureFetching
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(pairsService: SimpleBuySupportedPairsInteractorServiceAPI,
                featureFetcher: FeatureFetching) {
        self.featureFetcher = featureFetcher
        self.pairsService = pairsService
        
        cachedValue
            .setFetch(weak: self) { (self) -> Observable<Bool> in
                featureFetcher.fetchBool(for: .simpleBuyEnabled)
                    .asObservable()
                    .flatMapLatest { isFeatureEnabled -> Observable<Bool> in
                        guard isFeatureEnabled else {
                            return .just(false)
                        }
                        return pairsService.valueObservable
                            .map { $0.contains(oneOf: Constant.supportedFiatCurrencies) }
                    }
            }
    }
    
    // MARK: - API
    
    public func fetch() -> Single<Bool> {
        cachedValue.fetchValue
    }
}

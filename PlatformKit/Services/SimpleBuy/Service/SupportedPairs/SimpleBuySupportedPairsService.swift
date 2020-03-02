//
//  SimpleBuySupportedPairsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public final class SimpleBuySupportedPairsInteractorService: SimpleBuySupportedPairsInteractorServiceAPI {
    
    // MARK: - Public properties
    
    public var valueObservable: Observable<SimpleBuySupportedPairs> {
        cachedValue.valueObservable
    }
    
    public var valueSingle: Single<SimpleBuySupportedPairs> {
        cachedValue.valueSingle
    }
    
    // MARK: - Private properties
    
    private let cachedValue = CachedValue<SimpleBuySupportedPairs>()
    
    // MARK: - Setup
    
    public init(pairsService: SimpleBuySupportedPairsServiceAPI,
                fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI) {
        cachedValue
            .setFetch { () -> Observable<SimpleBuySupportedPairs> in
                fiatCurrencySettingsService.fiatCurrencyObservable
                    .map { .only(fiatCurrency: $0) }
                    .flatMapLatest { pairsService.fetchPairs(for: $0).asObservable() }
            }
    }
    
    public func fetch() -> Observable<SimpleBuySupportedPairs> {
        cachedValue.fetchValueObservable
    }
}

public final class SimpleBuySupportedPairsService: SimpleBuySupportedPairsServiceAPI {
    
    // MARK: - Injected
    
    private let client: SimpleBuySupportedPairsClientAPI
    
    // MARK: - Setup
    
    public init(client: SimpleBuySupportedPairsClientAPI) {
        self.client = client
    }
    
    // MARK: - SimpleBuySupportedPairsServiceAPI
    
    public func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairs> {
        client.supportedPairs(with: option)
            .map { SimpleBuySupportedPairs(response: $0, filterOption: option) }
    }
}

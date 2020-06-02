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

    private let cachedValue: CachedValue<SimpleBuySupportedPairs>

    // MARK: - Setup

    public init(featureFetcher: FeatureFetching,
                pairsService: SimpleBuySupportedPairsServiceAPI,
                fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI) {

        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-supported-pairs",
                refreshType: .periodic(seconds: 2),
                fetchPriority: .fetchAll,
                flushNotificationName: .logout,
                fetchNotificationName: .login)
        )

        cachedValue
            .setFetch { () -> Observable<SimpleBuySupportedPairs> in
                featureFetcher.fetchBool(for: .simpleBuyEnabled)
                    .asObservable()
                    .flatMapLatest { isFeatureEnabled -> Observable<SimpleBuySupportedPairs> in
                        guard isFeatureEnabled else {
                            return .just(.empty)
                        }
                        return fiatCurrencySettingsService
                            .fiatCurrencyObservable
                            .map { .only(fiatCurrency: $0) }
                            .flatMapLatest { pairsService.fetchPairs(for: $0).asObservable() }
                }
            }
    }

    public func fetch() -> Observable<SimpleBuySupportedPairs> {
        cachedValue.fetchValueObservable
    }
}

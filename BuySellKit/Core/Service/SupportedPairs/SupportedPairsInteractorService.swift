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
    var valueObservable: Observable<SupportedPairs> { get }
    var valueSingle: Single<SupportedPairs> { get }
    func fetch() -> Observable<SupportedPairs>
}

final class SupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {

    // MARK: - Public properties

    public var valueObservable: Observable<SupportedPairs> {
        cachedValue.valueObservable
    }

    public var valueSingle: Single<SupportedPairs> {
        cachedValue.valueSingle
    }

    // MARK: - Private properties

    private let cachedValue: CachedValue<SupportedPairs>

    // MARK: - Setup

    init(featureFetcher: FeatureFetching,
         pairsService: SupportedPairsServiceAPI,
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
            .setFetch { () -> Observable<SupportedPairs> in
                featureFetcher.fetchBool(for: .simpleBuyEnabled)
                    .asObservable()
                    .flatMapLatest { isFeatureEnabled -> Observable<SupportedPairs> in
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

    func fetch() -> Observable<SupportedPairs> {
        cachedValue.fetchValueObservable
    }
}

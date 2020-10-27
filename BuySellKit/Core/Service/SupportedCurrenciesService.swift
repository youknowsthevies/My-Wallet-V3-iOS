//
//  SupportedCurrenciesService.swift
//  PlatformKit
//
//  Created by Paulo on 01/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol SupportedCurrenciesServiceAPI: class {
    var supportedCurrencies: Single<Set<FiatCurrency>> { get }
}

final class SupportedCurrenciesService: SupportedCurrenciesServiceAPI {

    // MARK: - Public properties

    var supportedCurrencies: Single<Set<FiatCurrency>> {
        cachedValue.valueSingle
    }
    
    // MARK: - Private properties

    private let cachedValue: CachedValue<Set<FiatCurrency>>

    // MARK: - Setup

    init(featureFetcher: FeatureFetching = resolve(),
         pairsService: SupportedPairsServiceAPI = resolve(),
         fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI = resolve()) {

        cachedValue = .init(
            configuration: .init(
                identifier: "simple-buy-supported-currencies",
                refreshType: .onSubscription,
                flushNotificationName: .logout
            )
        )

        cachedValue
            .setFetch { () -> Single<Set<FiatCurrency>> in
                featureFetcher
                    .fetchBool(for: .simpleBuyEnabled)
                    .flatMap { isFeatureEnabled -> Single<Set<FiatCurrency>> in
                        guard isFeatureEnabled else {
                            return .just([])
                        }
                        return pairsService
                            .fetchPairs(for: .all)
                            .map { $0.fiatCurrencySet }
                    }
            }
    }
}

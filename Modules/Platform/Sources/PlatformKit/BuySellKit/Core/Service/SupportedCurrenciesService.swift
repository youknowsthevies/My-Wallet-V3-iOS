// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift
import RxToolKit
import ToolKit

public protocol SupportedCurrenciesServiceAPI: AnyObject {
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

    init(
        pairsService: SupportedPairsServiceAPI = resolve(),
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI = resolve()
    ) {

        cachedValue = CachedValue(
            configuration: .onSubscription(
                schedulerIdentifier: "SupportedCurrenciesService"
            )
        )

        cachedValue
            .setFetch { () -> Single<Set<FiatCurrency>> in
                pairsService
                    .fetchPairs(for: .all)
                    .map(\.fiatCurrencySet)
            }
    }
}

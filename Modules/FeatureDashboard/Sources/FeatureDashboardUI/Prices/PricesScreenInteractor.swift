// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

public final class PricesScreenInteractor {

    // MARK: - Properties

    var enabledCryptoCurrencies: [CryptoCurrency] {
        enabledCurrenciesService.allEnabledCryptoCurrencies
    }

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI

    // MARK: - Init

    public init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
    }

    // MARK: - Methods

    func assetPriceViewInteractor(
        for currency: CryptoCurrency
    ) -> AssetPriceViewInteracting {
        AssetPriceViewDailyInteractor(
            cryptoCurrency: currency,
            priceService: priceService,
            fiatCurrencyService: fiatCurrencyService
        )
    }

    func refresh() {}
}

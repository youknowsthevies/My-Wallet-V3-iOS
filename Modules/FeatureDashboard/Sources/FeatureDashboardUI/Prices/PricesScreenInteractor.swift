// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PricesScreenInteractor {

    // MARK: - Properties

    var enabledCryptoCurrencies: [CryptoCurrency] {
        enabledCurrenciesService.allEnabledCryptoCurrencies
    }

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let priceInteractors: [CryptoCurrency: AssetPriceViewInteracting]

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        priceInteractors = enabledCurrenciesService.allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: AssetPriceViewInteracting]()) { result, cryptoCurrency in
                result[cryptoCurrency] = AssetPriceViewDailyInteractor(
                    cryptoCurrency: cryptoCurrency,
                    priceService: priceService,
                    fiatCurrencyService: fiatCurrencyService
                )
            }
    }

    // MARK: - Methods

    func assetPriceViewInteractor(
        for currency: CryptoCurrency
    ) -> AssetPriceViewInteracting? {
        priceInteractors[currency]
    }

    func refresh() {
        priceInteractors.values.forEach { interactor in
            interactor.refresh()
        }
    }
}

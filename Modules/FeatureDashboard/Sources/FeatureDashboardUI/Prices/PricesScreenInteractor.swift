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

    private let disposeBag = DisposeBag()
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let historicalProvider: HistoricalFiatPriceProviding
    private let priceInteractors: [CryptoCurrency: AssetPriceViewInteractor]

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        historicalProvider: HistoricalFiatPriceProviding = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.historicalProvider = historicalProvider
        priceInteractors = enabledCurrenciesService.allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: AssetPriceViewInteractor]()) { result, cryptoCurrency in
                result[cryptoCurrency] = AssetPriceViewInteractor(
                    historicalPriceProvider: historicalProvider[cryptoCurrency]
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
        // TODO: IOS-4611: (paulo) Prices should not use historicalProvider.
        historicalProvider.refresh(window: .day(.oneHour))
    }
}

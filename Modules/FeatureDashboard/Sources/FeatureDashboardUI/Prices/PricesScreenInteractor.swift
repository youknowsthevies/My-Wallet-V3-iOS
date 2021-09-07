// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PricesScreenInteractor {

    // MARK: - Properties

    let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    let priceInteractors: [CryptoCurrency: AssetPriceViewInteractor]

    var enabledCryptoCurrencies: [CryptoCurrency] {
        enabledCurrenciesService.allEnabledCryptoCurrencies
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let historicalProvider: HistoricalFiatPriceProviding

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

    func refresh() {
        historicalProvider.refresh(window: .day(.oneHour))
    }
}

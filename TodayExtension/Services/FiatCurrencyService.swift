// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

final class FiatCurrencyService: FiatCurrencyServiceAPI {

    var legacyCurrency: FiatCurrency? {
        localeCurrency
    }

    var fiatCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        fatalError("unimplemented")
    }

    var fiatCurrencyObservable: Observable<FiatCurrency> {
        .just(localeCurrency)
    }

    var fiatCurrency: Single<FiatCurrency> {
        .just(localeCurrency)
    }

    private var localeCurrency: FiatCurrency {
        guard let code = Locale.current.currencyCode,
              let fiatCurrency = FiatCurrency(code: code)
        else {
            return .USD
        }
        return fiatCurrency
    }
}

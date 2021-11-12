// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit

final class FiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceAPI {

    private let fiatCurrencyRelay: BehaviorRelay<FiatCurrency>

    var fiatCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        fiatCurrency
            .asPublisher()
            .replaceError(with: .USD)
            .eraseToAnyPublisher()
    }

    var fiatCurrencyObservable: Observable<FiatCurrency> {
        fiatCurrencyRelay.asObservable()
    }

    var fiatCurrency: Single<FiatCurrency> {
        fiatCurrencyRelay.take(1).asSingle()
    }

    var legacyCurrency: FiatCurrency? {
        fiatCurrencyRelay.value
    }

    func update(currency: FiatCurrency, context: FlowContext) -> Completable {
        fiatCurrencyRelay.accept(currency)
        return .empty()
    }

    func update(currency: FiatCurrency, context: FlowContext) -> AnyPublisher<Void, CurrencyUpdateError> {
        fiatCurrencyRelay.accept(currency)
        return .just(())
    }

    init(expectedCurrency: FiatCurrency) {
        fiatCurrencyRelay = BehaviorRelay(value: expectedCurrency)
    }
}

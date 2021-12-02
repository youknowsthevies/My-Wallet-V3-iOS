// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit

final class FiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceAPI {

    private let fiatCurrencyRelay: BehaviorRelay<FiatCurrency>

    var displayCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        fiatCurrencyRelay
            .asObservable()
            .asPublisher()
            .replaceError(with: .USD)
            .eraseToAnyPublisher()
    }

    var displayCurrencyObservable: Observable<FiatCurrency> {
        displayCurrencyPublisher.asObservable()
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

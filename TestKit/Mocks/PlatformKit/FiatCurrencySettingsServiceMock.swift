//
//  FiatCurrencySettingsServiceMock.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class FiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceAPI {
    
    private let fiatCurrencyRelay: BehaviorRelay<FiatCurrency>
    
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
    
    init(expectedCurrency: FiatCurrency) {
        fiatCurrencyRelay = BehaviorRelay(value: expectedCurrency)
    }
}

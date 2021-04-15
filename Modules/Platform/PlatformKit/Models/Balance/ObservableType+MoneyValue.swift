//
//  ObservableType+MoneyValue.swift
//  PlatformKit
//
//  Created by Daniel on 21/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension Observable where Element == CryptoValue {
    public var moneyValue: Observable<MoneyValue> {
        map(\.moneyValue)
    }
}

extension Observable where Element == FiatValue {
    public var moneyValue: Observable<MoneyValue> {
        map(\.moneyValue)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == CryptoValue {
    public var moneyValue: Single<MoneyValue> {
        map(\.moneyValue)
    }
}
extension PrimitiveSequence where Trait == SingleTrait, Element == FiatValue {
    public var moneyValue: Single<MoneyValue> {
        map(\.moneyValue)
    }
}

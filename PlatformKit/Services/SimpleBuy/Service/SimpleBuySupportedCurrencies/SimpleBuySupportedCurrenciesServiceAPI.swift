//
//  SimpleBuySupportedCurrenciesServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 01/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuySupportedCurrenciesServiceAPI: class {
    var valueObservable: Observable<Set<FiatCurrency>> { get }
    var valueSingle: Single<Set<FiatCurrency>> { get }
    func fetch() -> Observable<Set<FiatCurrency>>
}

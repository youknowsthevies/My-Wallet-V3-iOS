//
//  CryptoCurrencyServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CryptoCurrencyServiceAPI: CurrencyServiceAPI {
    
    /// An `Observable` that streams `CryptoCurrency` values
    var cryptoCurrencyObservable: Observable<CryptoCurrency> { get }
    
    /// A `Single` that streams `CryptoCurrency` values
    var cryptoCurrency: Single<CryptoCurrency> { get }
}

extension CryptoCurrencyServiceAPI {
    
    public var currencyObservable: Observable<Currency> {
        cryptoCurrencyObservable.map { $0 as Currency }
    }
    
    public var currency: Single<Currency> {
        cryptoCurrency.map { $0 as Currency }
    }
}

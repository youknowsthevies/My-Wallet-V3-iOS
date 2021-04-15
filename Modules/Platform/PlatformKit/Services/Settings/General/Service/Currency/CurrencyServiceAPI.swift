//
//  CurrencyServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CurrencyServiceAPI: AnyObject {
    
    /// An `Observable` that streams `Currency` values
    var currencyObservable: Observable<Currency> { get }
    
    /// A `Single` that streams `Currency` values
    var currency: Single<Currency> { get }
}

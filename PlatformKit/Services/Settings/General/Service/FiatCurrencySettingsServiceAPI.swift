//
//  FiatCurrencySettingsServiceAPI.swift
//  PlatformKit
//
//  Created by Jack on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol FiatCurrencySettingsServiceAPI: class {
    
    /// An `Observable` that streams `FiatCurrency` values
    var fiatCurrencyObservable: Observable<FiatCurrency> { get }
    
    /// A `Single` that streams
    var fiatCurrency: Single<FiatCurrency> { get }
    
    /// Updates the fiat currency associated with the wallet
    /// - Parameter currency: The new fiat currency
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(currency: FiatCurrency, context: FlowContext) -> Completable
    
    @available(*, deprecated, message: "Do not use this. Prefer reactively getting the currency")
    var legacyCurrency: FiatCurrency? { get }
}

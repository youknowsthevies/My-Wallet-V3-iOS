//
//  FiatCurrencySettingsServiceAPI.swift
//  PlatformKit
//
//  Created by Jack on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol FiatCurrencySettingsServiceAPI: FiatCurrencyServiceAPI {
        
    /// Updates the fiat currency associated with the wallet
    /// - Parameter currency: The new fiat currency
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(currency: FiatCurrency, context: FlowContext) -> Completable
}

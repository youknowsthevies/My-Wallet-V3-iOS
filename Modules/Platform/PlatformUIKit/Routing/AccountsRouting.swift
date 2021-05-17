//
//  AccountsRouting.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol AccountsRouting {

    func routeToCustodialAccount(for currencyType: PlatformKit.CurrencyType)
    func routeToNonCustodialAccount(for currency: CryptoCurrency)
    func routeToInterestAccount(for currency: CryptoCurrency)
}

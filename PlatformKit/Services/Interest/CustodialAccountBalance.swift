//
//  CustodialAccountBalance.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct CustodialAccountBalance: Equatable {

    public let available: MoneyValue
    public let withdrawable: MoneyValue
    
    init(currency: CurrencyType, response: CustodialBalanceResponse.Balance) {
        self.available = (try? MoneyValue(minor: response.available, currency: currency.code)) ?? .zero(currency)
        self.withdrawable = (try? MoneyValue(minor: response.withdrawable, currency: currency.code)) ?? .zero(currency)
    }
    
    public init(available: MoneyValue, withdrawable: MoneyValue) {
        self.available = available
        self.withdrawable = withdrawable
    }
}

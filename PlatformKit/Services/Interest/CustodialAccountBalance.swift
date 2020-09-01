//
//  CustodialAccountBalance.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct CustodialAccountBalance: Equatable {

    public var available: MoneyValue
    public let withdrawable: MoneyValue
    
    init(currency: CurrencyType, response: CustodialBalanceResponse.Balance) {
        self.available = MoneyValue.create(minor: response.available, currency: currency) ?? .zero(currency: currency)
            self.withdrawable = MoneyValue.create(minor: response.withdrawable, currency: currency) ?? .zero(currency: currency)
    }
    
    public init(available: MoneyValue, withdrawable: MoneyValue) {
        self.available = available
        self.withdrawable = withdrawable
    }
}

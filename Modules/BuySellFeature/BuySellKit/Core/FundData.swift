//
//  FundData.swift
//  BuySellKit
//
//  Created by Daniel on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct FundData: Equatable {
    
    public let topLimit: FiatValue
    
    public let balance: MoneyValueBalancePairs
    
    init(topLimit: FiatValue, balance: MoneyValueBalancePairs) {
        self.topLimit = topLimit
        self.balance = balance
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct FundData: Equatable {
    
    public let topLimit: FiatValue
    
    public let balance: MoneyValueBalancePairs
    
    init(topLimit: FiatValue, balance: MoneyValueBalancePairs) {
        self.topLimit = topLimit
        self.balance = balance
    }
}

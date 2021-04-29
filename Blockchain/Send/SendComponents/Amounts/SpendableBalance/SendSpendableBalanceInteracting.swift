// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

/// The interaction layer for spendable balance on the send screen
protocol SendSpendableBalanceInteracting {
    
    /// Stream of the updated balance in account
    var calculationState: Observable<MoneyValuePairCalculationState> { get }
    
    /// The crypto balance, when applicable
    var balance: Observable<MoneyValuePair> { get }
}

// MARK: - SendSpendableBalanceInteracting (default)

extension SendSpendableBalanceInteracting {
    
    /// The balance in crypto. Elements are emitted only when the calculation state contains a valid value
    var balance: Observable<MoneyValuePair> {
        calculationState
            .compactMap { $0.value }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(
            requireSecondPassword: requiresSecondPassword,
            walletCurrencyService: DIKit.resolve(),
            currencyConversionService: DIKit.resolve(),
            feeService: DIKit.resolve(),
            transactionDispatcher: DIKit.resolve()
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(requireSecondPassword: requiresSecondPassword)
    }
}

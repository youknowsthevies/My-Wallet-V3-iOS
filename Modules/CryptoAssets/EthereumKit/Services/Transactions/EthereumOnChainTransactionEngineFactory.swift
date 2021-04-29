// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

class EthereumOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        EthereumOnChainTransactionEngine(requireSecondPassword: requiresSecondPassword)
    }
}

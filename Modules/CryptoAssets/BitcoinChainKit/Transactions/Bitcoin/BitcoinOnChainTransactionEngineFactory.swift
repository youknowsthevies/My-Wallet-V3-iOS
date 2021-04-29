// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

final class BitcoinOnChainTransactionEngineFactory<Token: BitcoinChainToken>: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        BitcoinOnChainTransactionEngine<Token>(requireSecondPassword: requiresSecondPassword)
    }
}

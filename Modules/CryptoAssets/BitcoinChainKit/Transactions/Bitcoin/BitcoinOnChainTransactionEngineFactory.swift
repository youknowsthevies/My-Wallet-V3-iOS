// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

public final class BitcoinOnChainTransactionEngineFactory<Token: BitcoinChainToken>: OnChainTransactionEngineFactory {
    public init() { }
    public func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        BitcoinOnChainTransactionEngine<Token>(requireSecondPassword: requiresSecondPassword)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

final class ERC20OnChainTransactionEngineFactory<Token: ERC20Token>: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        ERC20OnChainTransactionEngine<Token>(requireSecondPassword: requiresSecondPassword)
    }
}

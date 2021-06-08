// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import TransactionKit

final class ERC20OnChainTransactionEngineFactory: OnChainTransactionEngineFactory {

    private let erc20Token: ERC20Token

    init(erc20Token: ERC20Token) {
        self.erc20Token = erc20Token
    }

    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        ERC20OnChainTransactionEngine(
            erc20Token: erc20Token,
            requireSecondPassword: requiresSecondPassword
        )
    }
}

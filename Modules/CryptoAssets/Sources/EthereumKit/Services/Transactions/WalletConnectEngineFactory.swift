// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import PlatformKit

struct WalletConnectEngineFactory: WalletConnectEngineFactoryAPI {
    func build(
        target: TransactionTarget,
        onChainEngine: OnChainTransactionEngine
    ) -> TransactionEngine {
        switch target {
        case is EthereumSignMessageTarget:
            return EthereumSignMessageTransactionEngine()
        default:
            fatalError("Transaction target '\(type(of: target))' not supported.")
        }
    }
}

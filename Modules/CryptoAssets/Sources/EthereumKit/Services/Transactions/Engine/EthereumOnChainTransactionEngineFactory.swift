// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

class EthereumOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {

    private let network: EVMNetwork

    init(network: EVMNetwork) {
        self.network = network
    }

    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        EthereumOnChainTransactionEngine(
            network: network,
            requireSecondPassword: requiresSecondPassword
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import PlatformKit

struct WalletConnectEngineFactory: WalletConnectEngineFactoryAPI {
    func build(
        target: TransactionTarget
    ) -> TransactionEngine {
        switch target {
        case is EthereumSignMessageTarget:
            return WalletConnectSignMessageEngine()
        case let target as EthereumSendTransactionTarget:
            guard let network = target.currencyType.cryptoCurrency?.assetModel.evmNetwork else {
                fatalError("Target has invalid currency '\(target.currencyType.code)'.")
            }
            return WalletConnectTransactionEngine(
                requireSecondPassword: false,
                network: network
            )
        default:
            fatalError("Transaction target '\(type(of: target))' not supported.")
        }
    }
}

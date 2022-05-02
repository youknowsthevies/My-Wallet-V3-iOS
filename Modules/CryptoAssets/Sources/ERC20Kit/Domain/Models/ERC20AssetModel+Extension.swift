// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import MoneyKit

extension AssetModel {
    var contractAddress: EthereumAddress? {
        kind.contractAddress
    }
}

extension AssetModelType {
    var contractAddress: EthereumAddress? {
        switch self {
        case .erc20(let contractAddress, let network):
            return EthereumAddress(address: contractAddress, network: network.evmNetwork)
        case .coin, .fiat, .celoToken:
            return nil
        }
    }
}

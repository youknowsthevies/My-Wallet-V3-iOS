// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import MoneyKit

extension AssetModel {
    var contractAddress: EthereumAddress? {
        kind
            .erc20ContractAddress
            .flatMap(EthereumAddress.init(address:))
    }
}

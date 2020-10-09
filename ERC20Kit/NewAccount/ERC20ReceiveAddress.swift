//
//  ERC20Address.swift
//  ERC20Kit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit

struct ERC20ReceiveAddress: CryptoReceiveAddress {
    let asset: CryptoCurrency
    let address: String
    let label: String

    var metadata: CryptoAssetQRMetadata {
        EthereumURLPayload(address: address, amount: nil)!
    }

    init(asset: CryptoCurrency, address: String, label: String) {
        guard asset.isERC20 else {
            fatalError("Not an ERC20 Token")
        }
        self.asset = asset
        self.address = address
        self.label = label
    }
}

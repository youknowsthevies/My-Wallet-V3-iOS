//
//  EthereumReceiveAddress.swift
//  EthereumKit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct EthereumReceiveAddress: CryptoReceiveAddress {
    let asset: CryptoCurrency = .ethereum
    let address: String
    let label: String

    var metadata: CryptoAssetQRMetadata {
        EthereumURLPayload(address: address, amount: nil)!
    }
}

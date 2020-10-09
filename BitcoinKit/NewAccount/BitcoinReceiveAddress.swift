//
//  BitcoinReceiveAddress.swift
//  BitcoinKit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct BitcoinReceiveAddress: CryptoReceiveAddress {
    let asset: CryptoCurrency = .bitcoin
    let address: String
    let label: String

    var metadata: CryptoAssetQRMetadata {
        BitcoinURLPayload(address: address, amount: nil, includeScheme: true)
    }
}

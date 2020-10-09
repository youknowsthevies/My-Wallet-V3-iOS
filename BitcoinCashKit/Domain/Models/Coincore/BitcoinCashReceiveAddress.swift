//
//  BitcoinCashReceiveAddress.swift
//  BitcoinKit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct BitcoinCashReceiveAddress: CryptoReceiveAddress {
    let asset: CryptoCurrency = .bitcoinCash
    let address: String
    let label: String

    var metadata: CryptoAssetQRMetadata {
        BitcoinCashURLPayload(address: address, amount: nil, includeScheme: true)
    }
}

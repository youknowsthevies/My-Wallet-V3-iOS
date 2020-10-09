//
//  StellarAddress.swift
//  StellarKit
//
//  Created by Paulo on 21/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct StellarReceiveAddress: CryptoReceiveAddress {
    let asset: CryptoCurrency = .stellar
    let address: String
    let label: String

    var metadata: CryptoAssetQRMetadata {
        StellarURLPayload(address: address, amount: nil)
    }
}

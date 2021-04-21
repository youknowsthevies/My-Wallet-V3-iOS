//
//  EthereumReceiveAddress.swift
//  EthereumKit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

struct EthereumReceiveAddress: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {
    
    let asset: CryptoCurrency = .ethereum
    let address: String
    let label: String
    let onTxCompleted: TxCompleted
    
    var metadata: CryptoAssetQRMetadata {
        EthereumURLPayload(address: address, amount: nil)!
    }
    
    init(address: String, label: String, onTxCompleted: @escaping TxCompleted) {
        self.address = address
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}

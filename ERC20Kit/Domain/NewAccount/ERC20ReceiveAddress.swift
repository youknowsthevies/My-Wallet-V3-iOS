//
//  ERC20Address.swift
//  ERC20Kit
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import PlatformKit
import RxSwift

struct ERC20ReceiveAddress<Token: ERC20Token>: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {
    
    typealias TxCompleted = (TransactionResult) -> Completable
    
    let asset: CryptoCurrency
    let address: String
    let label: String
    let onTxCompleted: TxCompleted
    
    var metadata: CryptoAssetQRMetadata {
        EthereumURLPayload(address: address, amount: nil)!
    }
    
    init(asset: CryptoCurrency,
         address: String,
         label: String,
         onTxCompleted: @escaping TxCompleted) {
        guard asset.isERC20 else {
            fatalError("Not an ERC20 Token")
        }
        self.onTxCompleted = onTxCompleted
        self.asset = asset
        self.address = address
        self.label = label
    }
}

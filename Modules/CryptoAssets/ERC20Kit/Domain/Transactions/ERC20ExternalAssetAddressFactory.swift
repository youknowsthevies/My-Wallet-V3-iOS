//
//  ERC20ExternalAssetAddressFactory.swift
//  ERC20Kit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import TransactionKit

final class ERC20ExternalAssetAddressFactory<Token: ERC20Token>: CryptoReceiveAddressFactory {
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        ERC20ReceiveAddress<Token>(asset: Token.assetType, address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

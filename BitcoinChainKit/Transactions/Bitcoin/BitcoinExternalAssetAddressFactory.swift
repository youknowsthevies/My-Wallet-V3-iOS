//
//  BitcoinExternalAssetAddressFactory.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 12/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import TransactionKit

final class BitcoinChainExternalAssetAddressFactory<Token: BitcoinChainToken>: CryptoReceiveAddressFactory {
    
    typealias TxCompleted = (TransactionResult) -> Completable
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        BitcoinChainReceiveAddress<Token>(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }
}

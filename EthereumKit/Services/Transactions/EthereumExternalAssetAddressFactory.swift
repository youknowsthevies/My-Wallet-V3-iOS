//
//  EthereumExternalAssetAddressFactory.swift
//  EthereumKit
//
//  Created by Alex McGregor on 12/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import TransactionKit

final class EthereumExternalAssetAddressFactory: CryptoReceiveAddressFactory {
    func makeExternalAssetAddress(address: String,
                                  label: String,
                                  onTxCompleted: @escaping (TransactionResult) -> Completable) throws -> CryptoReceiveAddress {
        EthereumReceiveAddress(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

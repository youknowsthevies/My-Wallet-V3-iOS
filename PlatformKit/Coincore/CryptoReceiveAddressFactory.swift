//
//  AssetAddressFactory.swift
//  PlatformKit
//
//  Created by Paulo on 09/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

// Resolve this protocol with a CryptoCurrency tag to receive a factory that builds CryptoReceiveAddress.
public protocol CryptoReceiveAddressFactory {
    func makeExternalAssetAddress(address: String,
                                  label: String,
                                  onTxCompleted: @escaping (TransactionResult) -> Completable) throws -> CryptoReceiveAddress
}

public final class CryptoReceiveAddressFactoryService {

    public init() {}

    public func makeExternalAssetAddress(asset: CryptoCurrency,
                                         address: String,
                                         label: String,
                                         onTxCompleted: @escaping (TransactionResult) -> Completable) throws -> CryptoReceiveAddress {
        let factory = { () -> CryptoReceiveAddressFactory in resolve(tag: asset) }()
        return try factory.makeExternalAssetAddress(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

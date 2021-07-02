// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public enum CryptoReceiveAddressFactoryError: Error {
    case invalidAddress
}

/// Resolve this protocol with a `CryptoCurrency.typeTag` to receive a factory that builds `CryptoReceiveAddress`.
public protocol CryptoReceiveAddressFactory {

    typealias TxCompleted = (TransactionResult) -> Completable

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

public final class CryptoReceiveAddressFactoryService {

    public func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        let factory = { () -> CryptoReceiveAddressFactory in resolve(tag: asset.typeTag) }()
        return factory.makeExternalAssetAddress(
            asset: asset,
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }
}

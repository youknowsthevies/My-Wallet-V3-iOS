// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

/// Resolve this protocol with a CryptoCurrency tag to receive a factory that builds CryptoReceiveAddress.
public protocol CryptoReceiveAddressFactory {
    
    typealias TxCompleted = (TransactionResult) -> Completable
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress
}

public final class CryptoReceiveAddressFactoryService {
    
    public func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, Error> {
        let factory = { () -> CryptoReceiveAddressFactory in resolve(tag: asset) }()
        do {
            let address = try factory.makeExternalAssetAddress(address: address, label: label, onTxCompleted: onTxCompleted)
            return .success(address)
        } catch {
            return .failure(error)
        }
    }
}

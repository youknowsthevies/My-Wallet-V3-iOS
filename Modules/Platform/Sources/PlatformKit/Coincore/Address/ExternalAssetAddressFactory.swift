// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// A protocol defining a component that creates a `CryptoReceiveAddress`.
public protocol ExternalAssetAddressFactory {

    typealias TxCompleted = (TransactionResult) -> Completable

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

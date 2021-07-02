// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import PlatformKit
import RxSwift
import TransactionKit

final class ERC20ExternalAssetAddressFactory: CryptoReceiveAddressFactory {

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        guard EthereumAddress(address: address) != nil else {
            return .failure(.invalidAddress)
        }
        return .success(
            ERC20ReceiveAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
        )
    }
}

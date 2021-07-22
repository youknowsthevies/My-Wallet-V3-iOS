// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import TransactionKit

final class EthereumExternalAssetAddressFactory: CryptoReceiveAddressFactory {

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        guard EthereumAddress(address: address) != nil else {
            return .failure(.invalidAddress)
        }
        return .success(EthereumReceiveAddress(address: address, label: label, onTxCompleted: onTxCompleted))
    }
}

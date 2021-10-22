// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import RxSwift

final class EthereumExternalAssetAddressFactory: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        guard EthereumAddress(address: address.removing(prefix: "ethereum:")) != nil else {
            return .failure(.invalidAddress)
        }
        return .success(
            EthereumReceiveAddress(
                address: address.removing(prefix: "ethereum:"),
                label: label,
                onTxCompleted: onTxCompleted
            )
        )
    }
}

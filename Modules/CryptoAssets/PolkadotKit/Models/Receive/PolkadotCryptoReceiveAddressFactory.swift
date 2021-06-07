// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class PolkadotCryptoReceiveAddressFactory: CryptoReceiveAddressFactory {

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        PolkadotReceiveAddress(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

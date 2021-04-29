// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class AlgorandCryptoReceiveAddressFactory: CryptoReceiveAddressFactory {
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        AlgorandReceiveAddress(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

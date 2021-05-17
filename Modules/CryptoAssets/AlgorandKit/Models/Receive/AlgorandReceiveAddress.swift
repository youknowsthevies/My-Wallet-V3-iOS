// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

struct AlgorandReceiveAddress: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {

    let asset: CryptoCurrency = .algorand
    let address: String
    let label: String
    let onTxCompleted: TxCompleted

    var metadata: CryptoAssetQRMetadata {
        AlgorandURLPayload(address: address)
    }

    init(address: String, label: String, onTxCompleted: @escaping TxCompleted) {
        self.address = address
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}

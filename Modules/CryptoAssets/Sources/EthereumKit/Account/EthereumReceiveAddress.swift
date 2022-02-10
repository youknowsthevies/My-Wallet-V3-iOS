// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxSwift

struct EthereumReceiveAddress: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {

    var asset: CryptoCurrency {
        eip681URI.cryptoCurrency
    }

    var address: String {
        eip681URI.address
    }

    var metadata: CryptoAssetQRMetadata {
        eip681URI
    }

    let label: String
    let onTxCompleted: TxCompleted
    let eip681URI: EIP681URI

    init(
        eip681URI: EIP681URI,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.eip681URI = eip681URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }

    init?(address: String, label: String, onTxCompleted: @escaping TxCompleted) {
        guard let eip681URI = EIP681URI(address: address, cryptoCurrency: .coin(.ethereum)) else {
            return nil
        }
        self.eip681URI = eip681URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}

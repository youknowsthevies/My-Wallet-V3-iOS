// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import TransactionKit

final class BitcoinChainExternalAssetAddressFactory<Token: BitcoinChainToken>: CryptoReceiveAddressFactory {
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        switch Token.coin {
        case .bitcoin:
            return BitcoinChainReceiveAddress<BitcoinToken>(address: address, label: label, onTxCompleted: onTxCompleted)
        case .bitcoinCash:
            let address = address.removing(prefix: "\(AssetConstants.URLSchemes.bitcoinCash):")
            return BitcoinChainReceiveAddress<BitcoinCashToken>(address: address, label: label, onTxCompleted: onTxCompleted)
        }
    }
}

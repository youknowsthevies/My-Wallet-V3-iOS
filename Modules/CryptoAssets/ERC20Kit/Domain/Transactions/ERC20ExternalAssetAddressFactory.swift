// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import TransactionKit

final class ERC20ExternalAssetAddressFactory<Token: ERC20Token>: CryptoReceiveAddressFactory {
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        ERC20ReceiveAddress<Token>(asset: Token.assetType, address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

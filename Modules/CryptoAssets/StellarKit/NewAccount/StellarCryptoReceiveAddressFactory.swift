// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import TransactionKit

final class StellarCryptoReceiveAddressFactory: CryptoReceiveAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        let items = address.split(separator: ":")
        guard let address = items.first else {
            throw TransactionValidationFailure(state: .invalidAddress)
        }
        let memo = String(items.last ?? "")
        return StellarReceiveAddress(
            address: String(address),
            label: label,
            memo: memo.count > 0 ? memo : nil,
            onTxCompleted: onTxCompleted
        )
    }
}

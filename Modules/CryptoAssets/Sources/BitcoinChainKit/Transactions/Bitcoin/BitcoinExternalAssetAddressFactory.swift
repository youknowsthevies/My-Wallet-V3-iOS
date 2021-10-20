// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit
import WalletCore

final class BitcoinCashExternalAssetAddressFactory: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        let address = address.removing(prefix: "\(BitcoinCashURLPayload.scheme):")
        guard WalletCore.CoinType.bitcoinCash.validate(address: address) else {
            return .failure(.invalidAddress)
        }
        return .success(
            BitcoinChainReceiveAddress<BitcoinCashToken>(
                address: address,
                label: label,
                onTxCompleted: onTxCompleted
            )
        )
    }
}

final class BitcoinExternalAssetAddressFactory: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        let address = address.removing(prefix: "\(BitcoinURLPayload.scheme):")
        guard WalletCore.CoinType.bitcoin.validate(address: address) else {
            return .failure(.invalidAddress)
        }
        return .success(
            BitcoinChainReceiveAddress<BitcoinToken>(
                address: address,
                label: label,
                onTxCompleted: onTxCompleted
            )
        )
    }
}

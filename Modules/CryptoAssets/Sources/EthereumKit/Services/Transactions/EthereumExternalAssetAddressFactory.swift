// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import WalletCore

/// ExternalAssetAddressFactory implementation for Ethereum.
///
/// This factory will first try to create a EthereumReceiveAddress assuming the input is a EIP681URI, so
/// to preserve any extra information (eg amount), if that fails it tries to create EthereumReceiveAddress
/// by assuming the input is an address.
final class EthereumExternalAssetAddressFactory: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        eip681URI(address: address, label: label, onTxCompleted: onTxCompleted)
            .flatMapError { _ in
                self.ethereumReceiveAddress(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            }
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is a BIP21URI.
    private func eip681URI(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // Creates BIP21URI from url.
        guard let eip681URI = EIP681URI(url: address, enabledCurrenciesService: resolve()) else {
            return .failure(.invalidAddress)
        }
        // Validates the address is valid.
        guard Self.validate(address: eip681URI.address) else {
            return .failure(.invalidAddress)
        }
        // Creates BitcoinChainReceiveAddress from 'BIP21URI'.
        let receiveAddress = EthereumReceiveAddress(
            eip681URI: eip681URI,
            label: label,
            onTxCompleted: onTxCompleted
        )
        return .success(receiveAddress)
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is not a BIP21URI, just a plain address.
    private func ethereumReceiveAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // Removes the prefix, if present.
        let address = address.removing(prefix: "ethereum:")
        // Validates the address is valid.
        guard Self.validate(address: address) else {
            return .failure(.invalidAddress)
        }
        // Creates EthereumReceiveAddress from 'address'.
        guard let receiveAddress = EthereumReceiveAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        ) else {
            return .failure(.invalidAddress)
        }
        // Return success.
        return .success(receiveAddress)
    }

    private static func validate(address: String) -> Bool {
        WalletCore.CoinType.ethereum.validate(address: address)
            && EthereumAddress(address: address) != nil
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import ERC20Kit
import EthereumKit
import PlatformKit
import StellarKit

class AssetAddressFactory {
    /// Creates the appropriate concrete instance of an `AssetAddress` provided an
    /// address string and the desired asset type.
    ///
    /// - Parameters:
    ///   - address: the address of the asset
    ///   - assetType: the type of the asset
    /// - Returns: the concrete AssetAddress
    static func create(fromAddressString address: String, assetType: CryptoCurrency) -> AssetAddress {
        switch assetType {
        case .algorand,
             .polkadot:
            fatalError("\(assetType.name) not supported.")
        case .bitcoin:
            return BitcoinAssetAddress(publicKey: address)
        case .bitcoinCash:
            return BitcoinCashAssetAddress(publicKey: address)
        case .erc20:
            return ERC20AssetAddress(publicKey: address, cryptoCurrency: assetType)
        case .ethereum:
            return EthereumAddress(stringLiteral: address)
        case .stellar:
            return StellarAssetAddress(publicKey: address)
        }
    }

    /// Creates the appropriate concrete instances of an `AssetAddress` provided a string
    /// array of addresses and the desired asset type.
    ///
    /// - Parameters:
    ///   - address: the address of the asset
    ///   - assetType: the type of the asset
    /// - Returns: an array of the concrete AssetAddress instances
    static func create(
        fromAddressStringArray addressArray: [String],
        assetType: CryptoCurrency
    ) -> [AssetAddress] {
        var createdAddresses = [AssetAddress]()
        addressArray.forEach {
            createdAddresses.append(create(fromAddressString: $0, assetType: assetType))
        }
        return createdAddresses
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import WalletCore
import WalletPayloadKit

enum EthereumDerivationPath {
    static let purpose: UInt32 = 44
    static let coin: UInt32 = 60
    static let changeIndex: UInt32 = 0
    static let addressIndex: UInt32 = 0

    /// Returns a string in the format of `m/44'/60/{accountIndex}'/0/0`
    static func path(accountIndex: UInt32) -> String {
        path(accountIndex: accountIndex, changeIndex: changeIndex, addressIndex: addressIndex)
    }

    /// Returns a string in the format of `m/44'/60/{accountIndex}'/0/addressIndex`
    static func path(accountIndex: UInt32, addressIndex: UInt32) -> String {
        "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(changeIndex)/\(addressIndex)"
    }

    /// Returns a string in the format of `m/44'/60/{accountIndex}'/changeIndex/addressIndex`
    static func path(accountIndex: UInt32, changeIndex: UInt32, addressIndex: UInt32) -> String {
        "m/\(purpose)'/\(coin)'/\(accountIndex)'/\(changeIndex)/\(addressIndex)"
    }
}

/// Generates a `WalltCore.PrivateKey` with the given parameters
/// - Parameters:
///   - hdWallet: A `WalletCore.HDWallet`
///   - accountIndex: A `UInt` for the account index
/// - Returns: A `WalletCore.PrivateKey`
func generatePrivateKey(
    hdWallet: WalletCore.HDWallet,
    accountIndex: UInt32
) -> WalletCore.PrivateKey {
    generatePrivateKey(
        hdWallet: hdWallet,
        accountIndex: accountIndex,
        changeIndex: EthereumDerivationPath.changeIndex,
        addressIndex: EthereumDerivationPath.addressIndex
    )
}

/// Generates a `WalltCore.PrivateKey` with the given parameters
/// - Parameters:
///   - hdWallet: A `WalletCore.HDWallet`
///   - accountIndex: A `UInt` for the account index
///   - changeIndex: A `UInt` for the change index
///   - addressIndex: A `UInt` for the address index
/// - Returns: A `WalletCore.PrivateKey`
func generatePrivateKey(
    hdWallet: WalletCore.HDWallet,
    accountIndex: UInt32,
    changeIndex: UInt32,
    addressIndex: UInt32
) -> WalletCore.PrivateKey {
    let derivationPath = EthereumDerivationPath.path(
        accountIndex: accountIndex,
        changeIndex: changeIndex,
        addressIndex: addressIndex
    )
    return hdWallet.getKey(
        coin: .ethereum,
        derivationPath: derivationPath
    )
}

/// Generates an ETH address from the given key
/// - Parameter privateKey: A `WalletCore.PrivateKey` for the derivation of the address
/// - Returns: A `String`
func generateEthereumAddress(
    privateKey: WalletCore.PrivateKey
) -> String {
    WalletCore.CoinType.ethereum.deriveAddress(privateKey: privateKey)
}

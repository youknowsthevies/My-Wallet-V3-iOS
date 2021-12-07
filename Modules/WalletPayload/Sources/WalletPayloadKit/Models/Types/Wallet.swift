// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// The derived Wallet from the response model, `BlockchainWallet`
final class Wallet {
    var guid: String
    var sharedKey: String
    var doubleEncrypted: Bool
    var doublePasswordHash: String?
    var metadataHDNode: String

    var options: Options
    var hdWallets: [HDWallet]

    /// Returns the default HDWallet from the list
    /// - NOTE: We never add multiple HDWallet(s)
    var defaultHDWallet: HDWallet? {
        hdWallets.first
    }

    init(from blockchainWallet: BlockchainWallet) {
        guid = blockchainWallet.guid
        sharedKey = blockchainWallet.sharedKey
        doubleEncrypted = blockchainWallet.doubleEncryption
        doublePasswordHash = blockchainWallet.doublePasswordHash
        metadataHDNode = blockchainWallet.metadataHDNode
        options = blockchainWallet.options
        hdWallets = blockchainWallet.hdWallets
    }
}

/// Returns the seedHex from the given wallet
/// - Parameters:
///   - wallet: A `Wallet` object to retrieve the seedHex
///   - secondPassword: An optional String representing the second password
/// - Returns: `Result<String, WalletError>`
func getSeedHex(
    from wallet: Wallet,
    secondPassword: String? = nil
) -> Result<String, WalletError> {
    guard let seedHex = wallet.defaultHDWallet?.seedHex else {
        return .failure(.initialization(.missingSeedHex))
    }
    if wallet.doubleEncrypted {
        guard let secondPassword = secondPassword else {
            return .failure(.initialization(.needsSecondPassword))
        }
        return decryptValue(
            secondPassword: secondPassword,
            wallet: wallet,
            value: seedHex
        )
    }
    return .success(seedHex)
}

// MARK: - Second Password

/// Decrypts a value using a second password
/// - Parameters:
///   - secondPassword: A `String` value representing the user's second password
///   - wallet: A `Wallet` object
///   - value: A `String` encrypted value to be decrypted
/// - Returns: A `Result<String, WalletError>` with a decrypted value or a failure
func decryptValue(
    secondPassword: String,
    wallet: Wallet,
    value: String
) -> Result<String, WalletError> {
    validateSecondPassword(
        password: secondPassword,
        wallet: wallet
    ) { wallet in
        decryptValue(
            using: secondPassword,
            sharedKey: wallet.sharedKey,
            pbkdf2Iterations: wallet.options.pbkdf2Iterations,
            value: value
        )
        .mapError(WalletError.map(from:))
    }
}

/// Validates if a second password is correct or fails
/// - Parameters:
///   - password: A `String` value representing the user's second password
///   - wallet: A `Wallet` value
///   - perform: A closure to perform second password decryption
/// - Returns: `Result<Value, WalletError>`
func validateSecondPassword<Value>(
    password: String,
    wallet: Wallet,
    perform: (Wallet) -> Result<Value, WalletError>
) -> Result<Value, WalletError> {
    guard isValid(secondPassword: password, wallet: wallet) else {
        return .failure(.initialization(.invalidSecondPassword))
    }
    return perform(wallet)
}

/// Validates whether the given second password is valid
/// - Parameters:
///   - secondPassword: A `String` for the second password
///   - wallet: A `Wallet` value
/// - Returns: `true` if the given secondPassword matches the stored one, otherwise `false`
func isValid(secondPassword: String, wallet: Wallet) -> Bool {
    guard wallet.doubleEncrypted else {
        return false
    }
    let iterations = wallet.options.pbkdf2Iterations
    let sharedKey = wallet.sharedKey
    let computedHash = hashNTimes(iterations: iterations, value: sharedKey + secondPassword)
    return wallet.doublePasswordHash == computedHash
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol WalletManagerAPI: WalletManagerReactiveAPI {

    /// Provides access to the `ReactiveWalletAPI` implementation
    var reactiveWallet: ReactiveWalletAPI { get }

    /// Loads the wallet JS
    /// Calls `loadJS` on wallet
    func loadWalletJS()

    /// Fetches the wallet with the given password
    /// - Parameter password: A `String` for decrypting the wallet
    func fetch(with password: String)

    /// Returns `true` if the wallet is initialized, otherwise `false`
    func walletIsInitialized() -> Bool

    /// Returns `true` if the wallet is double encrypted, otherwise `false`
    func walletNeedsSecondPassword() -> Bool

    func walletGetHistoryForAllAssets()

    /// Forgets the current wallet, if any
    func forgetWallet()

    /// Create a new wallet account with the given details
    /// - Parameters:
    ///   - password: A `String` representing the password
    ///   - email: A `String` representing the email
    func newWallet(password: String, email: String)

    /// Creates a new wallet with the given details
    func load(with guid: String, sharedKey: String, password: String)

    /// Set the `Wallet` property `isNew` to `true`
    func markWalletAsNew()

    /// Recovers a wallet from metadata using a given seed phrase
    func recoverFromMetadata(seedPhrase: String)

    /// Recovers a wallet by creating a new wallet using a given seed phrase (new GUID)
    func recover(email: String, password: String, seedPhrase: String)

    /// Performs cleanup on methods
    func close()
}

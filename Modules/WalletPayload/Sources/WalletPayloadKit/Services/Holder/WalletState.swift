// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

/// An internal enum keeping track of the current state of `Wallet` and `MetadataState`
///
/// - note: The app requires both the `Wallet` model and `MetadataState` to be available in order to function correctly.
///
/// Accessing the wallet can happen using the following methods:
/// 1. Create a brand new Wallet and Metadata and sync with server
/// 2. Recover Account (using seed phrase, aka mnemonic)
///    - Using the seed phrase we initialize the metadata which contains the necessary info to login into an account
///    this makes the `MetadataState` available before having the `Wallet`.
/// 3. Login using pin (previously logged in)
///    - Using the pin we have already fetched the `Wallet`, after we decrypt using the password we store it
///    and then initialize the `MetadataState`
///
public enum WalletState {
    public enum PartiallyLoaded {
        case justMetadata(MetadataState)
        case justWallet(NativeWallet)
    }

    case partially(loaded: PartiallyLoaded)
    case loaded(wallet: NativeWallet, metadata: MetadataState)

    /// Returns `true` if both metadata and wallet has been initialized, otherwise `false`
    public var isInitialised: Bool {
        isMetadataInitialised && walletInitialized
    }

    public var wallet: NativeWallet? {
        switch self {
        case .partially(loaded: .justWallet(let wallet)):
            return wallet
        case .partially(loaded: .justMetadata):
            return nil
        case .loaded(wallet: let wallet, _):
            return wallet
        }
    }

    public var metadata: MetadataState? {
        switch self {
        case .partially(loaded: .justWallet):
            return nil
        case .partially(loaded: .justMetadata(let metadata)):
            return metadata
        case .loaded(_, metadata: let metadata):
            return metadata
        }
    }

    public var isMetadataInitialised: Bool {
        metadata != nil
    }

    public var walletInitialized: Bool {
        wallet != nil
    }
}

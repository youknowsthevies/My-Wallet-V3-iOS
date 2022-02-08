// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Holds the storage for wallet related access
public struct WalletRepoState: Equatable, Codable {

    /// Stores credential related properties
    public var credentials: WalletCredentials

    /// Stores informational related properties
    public var properties: WalletProperties

    /// Returns the encrypted wallet payload - (Base64, AES 256)
    public var encryptedPayload: WalletPayloadWrapper

    /// Provides an empty state
    public static let empty = WalletRepoState(
        credentials: .empty,
        properties: .empty,
        encryptedPayload: .init(pbkdf2IterationCount: 0, version: 0, payload: "")
    )
}

/// Holds credential information regarding the wallet
public struct WalletCredentials: Equatable, Codable {
    /// Returns the stored wallet identifier
    public var guid: String

    /// Returns the stored wallet shared key
    public var sharedKey: String

    /// Returns the stored session token
    public var sessionToken: String

    /// Returns the stored password
    public var password: String

    static let empty = WalletCredentials(
        guid: "",
        sharedKey: "",
        sessionToken: "",
        password: ""
    )
}

/// Holds informational properties regarding the wallet
public struct WalletProperties: Equatable, Codable {
    /// Returns `true` if the pub keys should be synchronised
    public var syncPubKeys: Bool

    // Returns the language as specified by the wallet
    public var language: String

    /// Returns the authenticator type, of the wallet
    public var authenticatorType: WalletAuthenticatorType

    static let empty = WalletProperties(
        syncPubKeys: false,
        language: "",
        authenticatorType: .standard
    )
}

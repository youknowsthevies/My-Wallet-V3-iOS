// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

public enum DerivationType: String, Equatable, CaseIterable {
    case legacy
    case segwit = "bech32"

    var purpose: Int {
        switch self {
        case .legacy:
            return 44
        case .segwit:
            return 84
        }
    }
}

public class Derivation: Equatable {
    var type: DerivationType
    var purpose: Int
    var xpriv: String
    var xpub: String
    var addressLabels: [AddressLabel]
    var cache: AddressCache

    public init(
        type: DerivationType,
        purpose: Int,
        xpriv: String,
        xpub: String,
        addressLabels: [AddressLabel],
        cache: AddressCache
    ) {
        self.type = type
        self.purpose = purpose
        self.xpriv = xpriv
        self.xpub = xpub
        self.addressLabels = addressLabels
        self.cache = cache
    }
}

extension Derivation {
    public static func == (lhs: Derivation, rhs: Derivation) -> Bool {
        lhs.type == rhs.type
            && lhs.purpose == rhs.purpose
            && lhs.xpriv == rhs.xpriv
            && lhs.xpub == rhs.xpub
            && lhs.addressLabels == rhs.addressLabels
            && lhs.cache == rhs.cache
    }
}

// MARK: - Creation Methods

/// Creates a `Derivation`.
/// - Parameters:
///   - privateKey: A `PrivateKey` created from a seedHex
///   - type: A `DerivationType`
/// - Returns: `Derivation`
func createDerivation(
    privateKey: PrivateKey,
    type: DerivationType
) -> Derivation {
    Derivation(
        type: type,
        purpose: type.purpose,
        xpriv: privateKey.xpriv,
        xpub: privateKey.xpub,
        addressLabels: [],
        cache: createAddressCache(from: privateKey)
    )
}

/// Creates a array of `Derivation`s using the types found in `DerivationType`
/// - Parameters:
///   - seedHex: A `String` to be used as a seed hex
///   - index: An `Int` for the private key derivation
/// - Returns: `Result<[Derivation], WalletCreateError>`
func generateDerivations(
    seedHex: String,
    index: Int
) -> [Derivation] {
    DerivationType.allCases
        .map { type in
            let key = deriveAccountKey(at: index, seedHex: seedHex, type: type)
            return createDerivation(privateKey: key, type: type)
        }
}

/// Derives a `PrivateKey` of path `m/(purpose)'/0'/(index)'`
/// - Parameters:
///   - index: An `Int` representing the _account_index_ to be used
///   - seedHex: A `String` to be used as a seed hex
///   - type: A `DerivationType` to extract its _purpose_
/// - Returns: A `Result<PrivateKey, WalletCreateError>`
func deriveAccountKey(
    at index: Int,
    seedHex: String,
    type: DerivationType
) -> PrivateKey {
    PrivateKey.bitcoinKeyFrom(seedHex: seedHex)
        .derive(at: .hardened(UInt32(type.purpose)))
        .derive(at: .hardened(0))
        .derive(at: .hardened(UInt32(index)))
}

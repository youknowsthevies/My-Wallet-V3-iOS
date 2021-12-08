// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import struct CryptoKit.SHA256
import Foundation
import MetadataHDWalletKit

public enum DeriveSecondPasswordNodeError: Error {
    case digestDataEncodingFailed
    case privateKeyInstantiationFailed
}

func deriveSecondPasswordNode(
    credentials: Credentials
) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> {
    deriveSecondPasswordNode(
        guid: credentials.guid,
        sharedKey: credentials.sharedKey,
        password: credentials.password
    )
}

private func deriveSecondPasswordNode(
    guid: String,
    sharedKey: String,
    password: String
) -> Result<SecondPasswordNode, DeriveSecondPasswordNodeError> {
    secondPasswordNodeEntropyHex(
        guid: guid,
        sharedkey: sharedKey,
        password: password
    )
    .flatMap { entropyHex -> Result<PrivateKey, DeriveSecondPasswordNodeError> in
        privateKeyFromEntropyHex(entropyHex: entropyHex)
    }
    .flatMap { privateKey -> Result<MetadataNode, DeriveSecondPasswordNodeError> in
        secondPasswordNodeFrom(privateKey: privateKey)
    }
    .map(SecondPasswordNode.init(metadataNode:))
}

private func secondPasswordNodeEntropyHex(
    guid: String,
    sharedkey: String,
    password: String
) -> Result<String, DeriveSecondPasswordNodeError> {
    .success(guid + sharedkey + password)
        .map(Data.from(utf8string:))
        .map { data in
            CryptoKit.SHA256.hash(data: data)
        }
        .map { sha256Digest -> String in
            sha256Digest.compactMap { String(format: "%02x", $0) }.joined()
        }
}

private func privateKeyFromEntropyHex(
    entropyHex: String
) -> Result<PrivateKey, DeriveSecondPasswordNodeError> {
    guard let key = PrivateKey.bitcoinKeyFrom(privateKeyHex: entropyHex) else {
        return .failure(.privateKeyInstantiationFailed)
    }
    return .success(key)
}

internal func secondPasswordNodeFrom(
    privateKey: PrivateKey
) -> Result<MetadataNode, DeriveSecondPasswordNodeError> {
    let node = MetadataNode(
        address: privateKey.address,
        node: privateKey,
        encryptionKey: privateKey.raw,
        type: .root
    )
    return .success(node)
}

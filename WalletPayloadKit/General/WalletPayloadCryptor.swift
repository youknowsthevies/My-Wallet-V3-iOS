//
//  WalletPayloadCryptor.swift
//  WalletKit
//
//  Created by Jack Pooley on 25/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit

/// Encrypts and Decrypts Blockchain Wallet Payloads
public protocol WalletPayloadCryptorAPI {
    
    /// Decrypts the Wallet Payload using a `KeyDataPair`
    /// - Parameters:
    ///   - pair: a `KeyDataPair` containing the decryption key and encrypted payload
    ///   - pbkdf2Iterations: the number of `PBKDF2` iterations
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, Error>
    
    /// Encrypts the Wallet Payload using a `KeyDataPair`
    /// - Parameters:
    ///   - pair: a `KeyDataPair` containing the encryption key and plaintext payload
    ///   - pbkdf2Iterations: the number of `PBKDF2` iterations
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, Error>
}

final class WalletPayloadCryptor: WalletPayloadCryptorAPI {
    
    private let payloadCrypto: PayloadCryptoAPI
    
    init(payloadCrypto: PayloadCryptoAPI = resolve()) {
        self.payloadCrypto = payloadCrypto
    }
    
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, Error> {
        payloadCrypto.decrypt(data: pair.data, with: pair.key, pbkdf2Iterations: pbkdf2Iterations)
            .eraseError()
    }
    
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, Error> {
        payloadCrypto.encrypt(data: pair.data, with: pair.key, pbkdf2Iterations: pbkdf2Iterations)
            .eraseError()
    }
}

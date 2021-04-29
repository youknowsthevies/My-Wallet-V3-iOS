// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import LibWally

public struct HDWallet {
    
    public var privateKey: HDPrivateKey {
        keychain.privateKey
    }
    
    public var publicKey: HDPublicKey {
        keychain.privateKey.publicKey
    }
    
    private let keychain: HDKeychain
    
    public init(keychain: HDKeychain) {
        self.keychain = keychain
    }
    
    public init(mnemonic: Mnemonic, network: Network) throws {
        let keychain: HDKeychain
        do {
            keychain = try HDKeychain(mnemonic: mnemonic, network: network)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        self.keychain = keychain
    }
    
    public func privateKey(at path: HDKeyPath) throws -> HDPrivateKey {
        try keychain.derivedKey(path: path)
    }
    
    public func publicKey(at path: HDKeyPath) throws -> HDPublicKey {
        try privateKey(at: path).publicKey
    }
}

extension HDWallet {
    
    public static func from(mnemonic: Mnemonic, network: Network) -> Result<HDWallet, HDWalletKitError> {
        Result { try HDWallet(mnemonic: mnemonic, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension HDWallet {
    
    public func privateKey(at path: HDKeyPath) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { try privateKey(at: path) }
            .mapError { $0 as! HDWalletKitError }
    }
    
    public func publicKey(at path: HDKeyPath) -> Result<HDPublicKey, HDWalletKitError> {
        Result { try publicKey(at: path) }
            .mapError { $0 as! HDWalletKitError }
    }
}

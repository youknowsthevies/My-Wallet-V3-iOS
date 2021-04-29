// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import LibWally

public struct HDPrivateKey: Equatable {
    
    public var xpriv: String? {
        libWallyKey.xpriv
    }
    
    public var xpub: String {
        libWallyKey.xpub
    }
    
    public var publicKey: HDPublicKey {
        HDPublicKey(data: libWallyKey.pubKey.data)
    }
    
    // FIXME: This is public for now but will eventually be private
    public let libWallyKey: LibWally.HDKey
    
    public init(seed: Seed, network: Network = .main(Bitcoin.self)) throws {
        guard let libWallySeed = BIP39Seed(seed.hexValue) else {
            throw HDWalletKitError.unknown
        }
        
        guard let key = LibWally.HDKey(libWallySeed, network.libWallyNetwork) else {
            throw HDWalletKitError.unknown
        }
        
        self.libWallyKey = key
    }
    
    // FIXME: This is public for now but will eventually be private
    public init(libWallyKey: LibWally.HDKey) {
        self.libWallyKey = libWallyKey
    }
    
    public func derive(at path: HDKeyPath) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { try libWallyKey.derive(path.libWallyPath) }
            .mapError { HDWalletKitError.libWallyError($0) }
            .map { HDPrivateKey(libWallyKey: $0) }
    }
    
    public func derive(at path: HDKeyPath) throws -> HDPrivateKey {
        try derive(at: path).get()
    }
    
    public static func == (lhs: HDPrivateKey, rhs: HDPrivateKey) -> Bool {
        lhs.xpriv == rhs.xpriv
            && lhs.xpub == rhs.xpub
    }
}

extension HDPrivateKey {
    public static func from(seed: Seed, network: Network = .main(Bitcoin.self)) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { try HDPrivateKey(seed: seed, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }
}

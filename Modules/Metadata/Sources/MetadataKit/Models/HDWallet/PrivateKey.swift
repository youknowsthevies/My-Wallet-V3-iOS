// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit

public enum PrivateKeyError: Error {
    case failedToDeserializePrivateKey(Error)
}

public struct PrivateKey {

    var xpriv: String {
        _hdWalletKey.extended()
    }

    var address: String {
        _hdWalletKey.publicKey.address
    }

    var raw: Data {
        _hdWalletKey.raw
    }

    var chainCode: Data {
        _hdWalletKey.chainCode
    }

    var index: UInt32 {
        _hdWalletKey.index
    }

    private let _hdWalletKey: MetadataHDWalletKit.PrivateKey

    init(_hdWalletKey: MetadataHDWalletKit.PrivateKey) {
        self._hdWalletKey = _hdWalletKey
    }

    // MARK: - Public methods

    public func wifCompressed() -> String {
        _hdWalletKey.wifCompressed()
    }

    public func derive(at path: HDKeyPath) -> PrivateKey {
        path.components
            .reduce(self) { result, component in
                result.derive(at: component)
            }
    }

    public func derive(at component: DerivationComponent) -> PrivateKey {
        let hdWalletKey = _hdWalletKey.derived(at: component.derivationNode)
        return PrivateKey(_hdWalletKey: hdWalletKey)
    }
}

extension PrivateKey: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        PrivateKey(
            address: \(address),
            chainCode: \(chainCode.hex),
            index: \(index.bigEndian),
            raw: \(raw.hex),
        )
        """
    }
}

extension PrivateKey {

    public static func bitcoinKeyFrom(seedHex: String) -> Result<Self, PrivateKeyError> {
        let seed = Data(hex: seedHex)
        let _hdWalletKey = MetadataHDWalletKit.PrivateKey(
            seed: seed,
            coin: Coin.bitcoin
        )
        let privateKey = Self(
            _hdWalletKey: _hdWalletKey
        )
        return .success(privateKey)
    }

    public static func bitcoinKeyFrom(privateKeyHex: String) -> Self? {
        guard let _hdWalletKey = MetadataHDWalletKit.PrivateKey(pk: privateKeyHex, coin: .bitcoin) else {
            return nil
        }
        return Self(_hdWalletKey: _hdWalletKey)
    }

    public static func bitcoinKeyFromXPriv(xpriv: String) -> Result<Self, PrivateKeyError> {
        MetadataHDWalletKit.PrivateKey.from(extended: xpriv)
            .mapError(PrivateKeyError.failedToDeserializePrivateKey)
            .map(Self.init(_hdWalletKey:))
    }
}

extension PrivateKey: Equatable {
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        lhs._hdWalletKey == rhs._hdWalletKey
    }
}

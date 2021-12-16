// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit
import ToolKit

private enum BitcoinConstants {

    static let bitcoinSignedMessageHeader = "Bitcoin Signed Message:\n"
    static let bitcoinSignedMessageHeaderBytes = Data(bitcoinSignedMessageHeader.utf8).bytes
}

public enum PrivateKeyError: Error {
    case failedToDeserializePrivateKey(Error)
    case failedToSignMessage
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

#if DEBUG
extension PrivateKey: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        PrivateKey(
            xpriv: \(xpriv)
            address: \(address),
            chainCode: \(chainCode.hex),
            index: \(index.bigEndian),
            raw: \(raw.hex),
        )
        """
    }
}
#endif

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

extension PrivateKey {

    func verify(
        bitcoinMessage message: String,
        signatureBase64: String
    ) -> Result<Void, Error> {
        unimplemented()
    }

    func sign(
        bitcoinMessage message: String
    ) -> Result<String, Error> {

        func sign(
            message: String
        ) -> Result<String, Error> {

            func headerByte(recId: UInt8, isCompressed: Bool) -> UInt8 {
                recId + 27 + (isCompressed ? 4 : 0)
            }

            return Self.formatBTCMessageForSigning(message: message)
                .map(Data.init(_:))
                .flatMap { data -> Result<String, Error> in
                    let hash = data.doubleSHA256
                    return Result { try _hdWalletKey.sign(hash: hash) }
                        .map(\.bytes)
                        .flatMap { sigData -> Result<String, Error> in
                            guard sigData.count == 65 else {
                                return .failure(PrivateKeyError.failedToSignMessage)
                            }
                            let r = sigData[0..<32]
                            let s = sigData[32..<64]
                            let recId = sigData[64]

                            // 1 header + 32 bytes for R + 32 bytes for S
                            var output = [UInt8]()
                            output += [headerByte(recId: recId, isCompressed: true)] // TODO: isCompressed
                            output += r
                            output += s

                            let outputBase64 = output.toBase64()

                            return .success(outputBase64)
                        }
                }
        }

        return sign(message: message)
    }
}

extension PrivateKey {

    static func formatBTCMessageForSigning(
        message: String
    ) -> Result<[UInt8], Error> {
        var formattedBytes = [UInt8]()

        formattedBytes += [UInt8(BitcoinConstants.bitcoinSignedMessageHeaderBytes.count)]
        formattedBytes += BitcoinConstants.bitcoinSignedMessageHeaderBytes

        let messageBytes = Data(message.utf8).bytes
        let size = VarInt(value: messageBytes.count)

        formattedBytes += size.data
        formattedBytes += messageBytes

        return .success(formattedBytes)
    }
}

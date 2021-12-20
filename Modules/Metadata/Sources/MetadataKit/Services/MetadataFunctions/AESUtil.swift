// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoSwift
import Foundation

struct AESUtil {

    private enum Constants {
        static let AESBlockSize = 4
        static let saltBytes = AESBlockSize * 4
    }

    static func decryptWith(
        key base64EncodedKey: Data,
        payload: Data
    ) -> Result<Data, Error> {
        let key = base64EncodedKey.bytes
        let iv = Array(payload.bytes[0..<Constants.saltBytes])
        let payload = Array(payload.bytes[Constants.saltBytes..<payload.count])
        let padding: Padding = .iso10126

        return AES
            .create(
                with: key,
                blockMode: CBC(iv: iv),
                padding: padding
            )
            .flatMap { aes -> Result<[UInt8], AES.Error> in
                aes.decrypt(bytes: payload)
            }
            .map(Data.init(_:))
            .eraseError()
    }

    static func encryptWithKey(key: Data, data: Data) -> Result<Data, Error> {
        let iv = getSalt()
        let dataBytes = data.bytes
        let padding: Padding = .iso10126

        return AES
            .create(
                with: key.bytes,
                blockMode: CBC(iv: iv),
                padding: padding
            )
            .flatMap { aes -> Result<[UInt8], AES.Error> in
                aes.encrypt(bytes: dataBytes)
            }
            .map { encryptedBytes -> [UInt8] in
                iv + encryptedBytes
            }
            .map(Data.init(_:))
            .eraseError()
    }

    private static func getSalt() -> [UInt8] {

        func randomIV(_ count: Int) -> [UInt8] {
            (0..<count).map { _ in UInt8.random(in: 0...UInt8.max) }
        }

        return randomIV(Constants.AESBlockSize * 4)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoKit
import DIKit
import Foundation
import ToolKit

/// Hashes a value over n iterations using SHA256
/// - Parameters:
///   - iterations: An `Int` for the number of iterations for the hashed value
///   - value: A `String` of the initial value
/// - Returns: A `String` value hashed n times
func hashNTimes(iterations: Int, value: String) -> String {
    assert(iterations > 0)
    let data = Data(value.utf8)
    return (1...iterations)
        .reduce(into: data) { result, _ in
            result = Data(SHA256.hash(data: result))
        }
        .toHexString
}

/// Decrypts a value using a second password
/// - Parameters:
///   - secPassword: A `String` value representing the user's second password
///   - sharedKey: A `String` value of the sharedKey from `Wallet`
///   - pbkdf2Iterations: An `Int` value of the number of iterations for the decryption
///   - value: A `String` encrypted value to be decrypted
/// - Returns: A `Result<String, PayloadCryptoError>` with a decrypted value or a failure
func decryptValue(
    using secPassword: String,
    sharedKey: String,
    pbkdf2Iterations: Int,
    value: String,
    decryptor: PayloadCryptoAPI = PayloadCrypto(cryptor: AESCryptor())
) -> Result<String, PayloadCryptoError> {
    let isValueBase64Encoded = Data(base64Encoded: value) != nil
    let base64EncodedValue = isValueBase64Encoded ? value : Data(value.utf8).base64EncodedString()
    return decryptor.decrypt(
        data: base64EncodedValue,
        with: sharedKey + secPassword,
        pbkdf2Iterations: UInt32(pbkdf2Iterations)
    )
}

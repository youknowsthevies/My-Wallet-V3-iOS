// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine

final class MockPayloadCrypto: PayloadCryptoAPI {

    var decryptWalletDataCalled = false
    var decryptWalletDataResult: Result<String, PayloadCryptoError> = .failure(.decodingFailed)

    func decryptWallet(
        encryptedWalletData: String,
        password: String
    ) -> Result<String, PayloadCryptoError> {
        decryptWalletDataCalled = true
        return decryptWalletDataResult
    }

    var decryptWalletWrapperCalled = false
    var decryptWalletWrapperResult: Result<String, PayloadCryptoError> = .failure(.decodingFailed)

    func decryptWallet(
        walletWrapper: WalletPayloadWrapper,
        password: String
    ) -> Result<String, PayloadCryptoError> {
        decryptWalletWrapperCalled = true
        return decryptWalletWrapperResult
    }

    var decryptWalletBase64StringCalled = false
    var decryptWalletBase64StringResult: Result<String, PayloadCryptoError> = .failure(.decodingFailed)

    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32,
        options: AESOptions
    ) -> Result<String, PayloadCryptoError> {
        decryptWalletBase64StringCalled = true
        return decryptWalletBase64StringResult
    }

    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        decrypt(
            data: dataBase64String,
            with: key,
            pbkdf2Iterations: iterations,
            options: .default
        )
    }

    var encryptDataCalled = false
    var encryptDataResult: Result<String, PayloadCryptoError> = .failure(.decodingFailed)

    func encrypt(
        data payload: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        encryptDataCalled = true
        return encryptDataResult
    }
}

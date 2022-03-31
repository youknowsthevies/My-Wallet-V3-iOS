// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public enum WalletCryptoPBKDF2Iterations {
    /// Used for Auto Pair QR code decryption/encryption
    public static let autoPair = 10
    /// This does not need to be large because the key is already 256 bits
    public static let pinLogin = 1
}

public protocol WalletCryptoServiceAPI: AnyObject {
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError>
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError>
}

final class WalletCryptoService: WalletCryptoServiceAPI {

    // MARK: - Types

    private enum JSMethod: String {
        case decrypt = "WalletCrypto.decrypt(\"%@\", \"%@\", %ld)"
        case encrypt = "WalletCrypto.encrypt(\"%@\", \"%@\", %ld)"
    }

    // MARK: - Properties

    private let jsContextProvider: JSContextProviderAPI
    private let payloadCryptor: WalletPayloadCryptorAPI
    private let recorder: Recording

    // MARK: - Setup

    init(
        contextProvider: JSContextProviderAPI = resolve(),
        payloadCryptor: WalletPayloadCryptorAPI = resolve(),
        recorder: Recording = resolve(tag: "CrashlyticsRecorder")
    ) {
        jsContextProvider = contextProvider
        self.payloadCryptor = payloadCryptor
        self.recorder = recorder
    }

    // MARK: - Public methods

    /// Receives a `KeyDataPair` and decrypt `data` using `key`
    /// - Parameter pair: A pair of key and data used in the decription process.
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError> {
        decryptNative(pair: pair, pbkdf2Iterations: UInt32(pbkdf2Iterations))
            .publisher
            .catch { [decryptJS, recorder] payloadDecryptionError -> AnyPublisher<String, PayloadCryptoError> in
                decryptJS(pair, UInt32(pbkdf2Iterations))
                    .handleEvents(receiveOutput: { _ in
                        // For now log the error only
                        recorder.error(payloadDecryptionError)
                        // Crash for internal builds if JS decryption succeeds but native decryption fails
                        if BuildFlag.isInternal {
                            fatalError("Native decryption failed. Error: \(String(describing: payloadDecryptionError))")
                        }
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Receives a `KeyDataPair` and encrypt `data` using `key`.
    /// - Parameter pair: A pair of key and data used in the encription process.
    func encrypt(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: Int
    ) -> AnyPublisher<String, PayloadCryptoError> {
        encryptNative(pair: pair, pbkdf2Iterations: UInt32(pbkdf2Iterations))
            .publisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func encryptNative(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        payloadCryptor.encrypt(pair: pair, pbkdf2Iterations: pbkdf2Iterations)
    }

    private func decryptNative(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        payloadCryptor.decrypt(pair: pair, pbkdf2Iterations: pbkdf2Iterations)
    }

    private func decryptJS(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: UInt32
    ) -> AnyPublisher<String, PayloadCryptoError> {
        Deferred { [jsCrypto] in
            Future<String, PayloadCryptoError> { promise in
                let result = jsCrypto(
                    .decrypt,
                    pair.data,
                    pair.key,
                    Int(pbkdf2Iterations)
                )
                switch result {
                case .success(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func encryptJS(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: Int
    ) -> AnyPublisher<String, PayloadCryptoError> {
        Deferred { [jsCrypto] in
            Future<String, PayloadCryptoError> { promise in
                let result = jsCrypto(
                    .encrypt,
                    pair.data,
                    pair.key,
                    Int(pbkdf2Iterations)
                )
                switch result {
                case .success(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func jsCrypto(
        _ method: JSMethod,
        data: String,
        key: String,
        iterations: Int
    ) -> Result<String, PayloadCryptoError> {
        let data = data.escapedForJS()
        let key = key.escapedForJS()
        let script = String(format: method.rawValue, data, key, iterations)
        let jsContext = jsContextProvider.jsContext
        guard let result = jsContext.evaluateScriptCheckIsOnMainQueue(script)?.toString() else {
            return .failure(payloadCryptoError(from: method))
        }
        guard !result.isEmpty else {
            return .failure(payloadCryptoError(from: method))
        }
        return .success(result)
    }

    private func payloadCryptoError(
        from jsMethod: JSMethod
    ) -> PayloadCryptoError {
        switch jsMethod {
        case .decrypt:
            return .decryptionFailed
        case .encrypt:
            return .decryptionFailed
        }
    }
}

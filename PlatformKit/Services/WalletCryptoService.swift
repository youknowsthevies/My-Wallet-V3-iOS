//
//  WalletCryptoService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 17/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public enum WalletCryptoPBKDF2Iterations {
    /// Used for Auto Pair QR code decryption/encryption
    public static let autoPair: Int = 10
    /// This does not need to be large because the key is already 256 bits
    public static let pinLogin: Int = 1
}

public protocol WalletCryptoServiceAPI: class {
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> Single<String>
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> Single<String>
}

final class WalletCryptoService: WalletCryptoServiceAPI {

    // MARK: - Types

    enum ServiceError: Error {
        case emptyResult
        case failed
    }

    private enum JSMethod: String {
        case decrypt = "WalletCrypto.decrypt(\"%@\", \"%@\", %ld)"
        case encrypt = "WalletCrypto.encrypt(\"%@\", \"%@\", %ld)"
    }

    // MARK: - Properties

    private let jsContextProvider: JSContextProviderAPI

    // MARK: - Setup

    init(jsContextProvider: JSContextProviderAPI = resolve()) {
        self.jsContextProvider = jsContextProvider
    }

    // MARK: - Methods

    /// Receives a `KeyDataPair` and decrypt `data` using `key`
    /// - Parameter pair: A pair of key and data used in the decription process.
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> Single<String> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                do {
                    let result = try self.crypto(
                        .decrypt,
                        data: pair.data,
                        key: pair.key,
                        iterations: pbkdf2Iterations
                    )
                    observer(.success(result))
                } catch {
                    observer(.error(error))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }

    /// Receives a `KeyDataPair` and encrypt `data` using `key`.
    /// - Parameter pair: A pair of key and data used in the encription process.
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> Single<String> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                do {
                    let result = try self.crypto(
                        .encrypt,
                        data: pair.data,
                        key: pair.key,
                        iterations: pbkdf2Iterations
                    )
                    observer(.success(result))
                } catch {
                    observer(.error(error))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }

    // MARK: - Private methods

    /// TICKET: IOS-2735: Decrypt/Encrypt natively
    private func crypto(_ method: JSMethod,
                        data: String,
                        key: String,
                        iterations: Int) throws -> String {
        let data = data.escapedForJS()
        let key = key.escapedForJS()
        let script = String(format: method.rawValue, data, key, iterations)
        guard let result = jsContextProvider.jsContext.evaluateScript(script)?.toString() else {
            throw ServiceError.failed
        }
        guard !result.isEmpty else {
            throw ServiceError.emptyResult
        }
        return result
    }
}

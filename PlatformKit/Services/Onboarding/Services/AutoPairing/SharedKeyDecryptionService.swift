//
//  SharedKeyDecryptionService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 17/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

/// A shared key decryption service
final class SharedKeyDecryptionService {
    
    // MARK: - Types
    
    /// Potential errors
    enum ServiceError: Error {
        case emptySharedKey
        case sharedKeyDecryption
    }
    
    struct Constant {
        static let pbkdf2Iterations = 10
    }
    
    private struct JSMethod {
        
        /// This method is used to decrypt the shared-key using the shared-key decryption-key
        static let decrypt = "WalletCrypto.decrypt(\"%@\", \"%@\", %d)"
    }
    
    // MARK: - Properties
    
    private let jsContextProvider: JSContextProviderAPI
    
    // MARK: - Setup
    
    init(jsContextProvider: JSContextProviderAPI) {
        self.jsContextProvider = jsContextProvider
    }
    
    /// Receives a `KeyDataPair` and decrypt `data` (encrypted shared-key) using
    /// `key` (password), thus mapping it into the decrypted shared key.
    /// - Parameter pair: A pair of key and data used in the decription process.
    func decrypt(pair: KeyDataPair<String, String>) -> Single<String> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                do {
                    let sharedKey = try self.decrypt(
                        encryptedSharedKey: pair.data,
                        using: pair.key,
                        iterations: Constant.pbkdf2Iterations
                    )
                    observer(.success(sharedKey))
                } catch {
                    observer(.error(error))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    // MARK: - Private methods
    
    /// TICKET: https://blockchain.atlassian.net/browse/IOS-2735
    /// TODO: Decrypt shared key natively
    private func decrypt(encryptedSharedKey: String,
                         using decryptionKey: String,
                         iterations: Int) throws -> String {
        let encryptedSharedKey = encryptedSharedKey.escapedForJS()
        let decryptionKey = decryptionKey.escapedForJS()
        let script = String(format: JSMethod.decrypt, encryptedSharedKey, decryptionKey, Int32(iterations))
        guard let sharedKey = jsContextProvider.jsContext.evaluateScript(script)?.toString() else {
            throw ServiceError.sharedKeyDecryption
        }
        guard !sharedKey.isEmpty else {
            throw ServiceError.emptySharedKey
        }
        return sharedKey
    }
}

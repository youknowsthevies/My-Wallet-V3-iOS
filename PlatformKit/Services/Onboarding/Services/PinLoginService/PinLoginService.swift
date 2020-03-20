//
//  PinLoginService.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class PinLoginService: PinLoginServiceAPI {
    
    // MARK: - Types
    
    public typealias PasscodeRepositoryAPI = SharedKeyRepositoryAPI & GuidRepositoryAPI & PasswordRepositoryAPI
    
    /// Potential errors
    public enum ServiceError: Error {
        case missingEncryptedPassword
        case walletDecryption
        case emptyDecryptedPassword
        case missingGuid
        case missingSharedKey
    }

    // MARK: - Properties

    private let settings: ReactiveAppSettingsAuthenticating
    private let service: WalletPayloadServiceAPI
    private let walletRepository: PasscodeRepositoryAPI
    private let walletCrypto: WalletCryptoServiceAPI
    
    // MARK: - Setup
    
    public init(jsContextProvider: JSContextProviderAPI,
                settings: ReactiveAppSettingsAuthenticating,
                service: WalletPayloadServiceAPI,
                walletRepository: PasscodeRepositoryAPI) {
        self.service = service
        self.settings = settings
        self.walletRepository = walletRepository
        self.walletCrypto = WalletCryptoService(jsContextProvider: jsContextProvider)
    }
    
    public func password(from pinDecryptionKey: String) -> Single<String> {
        return service
            .requestUsingSharedKey()
            .flatMapSingle(weak: self) { (self) -> Single<PasscodePayload> in
                return Single
                    .zip(
                        self.walletRepository.guid,
                        self.decrypt(pinDecryptionKey: pinDecryptionKey),
                        self.walletRepository.sharedKey
                    )
                    .map { payload -> PasscodePayload in
                        // All the values must be present at the moment of invocation
                        return PasscodePayload(
                            guid: payload.0!,
                            password: payload.1,
                            sharedKey: payload.2!
                        )
                    }
            }
            .flatMap(weak: self) { (self, payload) -> Single<String> in
                return self.cache(passcodePayload: payload)
                    .andThen(Single.just(payload.password))
            }
    }
    
    /// Caches the passcode payload using wallet repository
    private func cache(passcodePayload: PasscodePayload) -> Completable {
        return Completable
            .zip(
                walletRepository.set(sharedKey: passcodePayload.sharedKey),
                walletRepository.set(password: passcodePayload.password),
                walletRepository.set(guid: passcodePayload.guid)
            )
    }

    private var encryptedPinPassword: Single<String> {
        return Single.create(weak: self) { (self, observer) -> Disposable in
            if let encryptedPassword = self.settings.encryptedPinPassword {
                observer(.success(encryptedPassword))
            } else {
                observer(.error(ServiceError.missingEncryptedPassword))
            }
            return Disposables.create()
        }
    }

    /// Decrypt the password using the PIN decryption key
    private func decrypt(pinDecryptionKey: String) -> Single<String> {
        return encryptedPinPassword
            .map { KeyDataPair<String, String>(key: pinDecryptionKey, data: $0) }
            .flatMap(weak: self) { (self, keyDataPair) -> Single<String> in
                self.walletCrypto.decrypt(pair: keyDataPair, pbkdf2Iterations: WalletCryptoPBKDF2Iterations.pinLogin)
            }
    }
}

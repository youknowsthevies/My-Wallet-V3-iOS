// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// TODO: Remove `NSObject` when `Wallet` is killed
/// A bridge to `Wallet` since it is an ObjC object.
@objc
final class WalletRepository: NSObject, WalletRepositoryAPI, WalletCredentialsProviding {
        
    // MARK: - Types
    
    private struct JSSetter {
        
        struct Password {
            static let change = "MyWalletPhone.changePassword(\"%@\")"
            static let success = "objc_on_change_password_success"
            static let error = "objc_on_change_password_error"
        }
        
        /// Accepts "true" / "false" as parameter
        static let syncPubKeys = "MyWalletPhone.setSyncPubKeys(%@)"
        
        /// Accepts a String representing the language
        static let language = "MyWalletPhone.setLanguage(\"%@\")"
        
        /// Accepts a String representing the wallet payload
        static let payload = "MyWalletPhone.setEncryptedWalletData(\"%@\")"
        
        /// Fetches the user offline token
        static let offlineToken = "MyWalletPhone.KYC.lifetimeToken()"
        
        /// Fetches the user id
        static let userId = "MyWalletPhone.KYC.userId()"
        
        /// Updates user credentials: userId, lifetimeToken
        static let updateUserCredentials = "MyWalletPhone.KYC.updateUserCredentials(\"%@\", \"%@\")"
    }
    
    private struct JSCallback {
        static let updateUserCredentialsSuccess = "objc_updateUserCredentials_success"
        static let updateUserCredentialsFailure = "objc_updateUserCredentials_error"
    }
    
    private let authenticatorTypeRelay = BehaviorRelay<AuthenticatorType>(value: .standard)
    private let sessionTokenRelay = BehaviorRelay<String?>(value: nil)
    private let passwordRelay = BehaviorRelay<String?>(value: nil)
    private let reactiveWallet: ReactiveWalletAPI

    // MARK: - Properties
    
    /// Streams the session token if exists
    var sessionToken: Single<String?> {
        sessionTokenRelay
            .take(1)
            .asSingle()
    }
    
    /// Streams the GUID if exists
    var guid: Single<String?> {
        settings.guid
    }

    /// Streams the shared key if exists
    var sharedKey: Single<String?> {
        settings.sharedKey
    }

    /// Streams the password if exists
    var password: Single<String?> {
        passwordRelay
            .take(1)
            .asSingle()
    }

    var authenticatorType: Single<AuthenticatorType> {
        authenticatorTypeRelay
            .take(1)
            .asSingle()
    }

    var offlineTokenResponse: Single<NabuOfflineTokenResponse> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                Single.zip(self.userId, self.offlineToken)
            }
            .map { payload -> (userId: String, offlineToken: String) in
                guard let userId = payload.0, !userId.isEmpty else {
                    throw MissingCredentialsError.userId
                }
                guard let offlineToken = payload.1, !offlineToken.isEmpty else {
                    throw MissingCredentialsError.offlineToken
                }
                return (userId, offlineToken)
            }
            .map { NabuOfflineTokenResponse(userId: $0.userId, token: $0.offlineToken) }
    }
    
    var offlineTokenResponsePublisher: AnyPublisher<NabuOfflineTokenResponse, MissingCredentialsError> {
        let userIdPublisher = self.userIdPublisher
        let offlineTokenPublisher = self.offlineTokenPublisher
        return reactiveWallet.waitUntilInitializedSinglePublisher
            .mapError()
            .flatMap { [userIdPublisher, offlineTokenPublisher] _ -> AnyPublisher<(String?, String?), WalletError> in
                Publishers.Zip(userIdPublisher, offlineTokenPublisher)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            .replaceError(with: MissingCredentialsError.offlineToken)
            .flatMap { userId, offlineToken -> AnyPublisher<(userId: String, offlineToken: String), MissingCredentialsError> in
                guard let userId = userId else {
                    return .failure(.userId)
                }
                guard let offlineToken = offlineToken else {
                    return .failure(.offlineToken)
                }
                return .just((userId: userId, offlineToken: offlineToken))
            }
            .map(NabuOfflineTokenResponse.init)
            .eraseToAnyPublisher()
    }
    
    private var offlineTokenPublisher: AnyPublisher<String?, WalletError> {
        let jsContextProvider = self.jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                guard WalletManager.shared.wallet.isInitialized() else {
                    promise(.failure(.notInitialized))
                    return
                }
                guard let jsValue = jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(JSSetter.offlineToken) else {
                    promise(.success(nil))
                    return
                }
                guard !jsValue.isNull, !jsValue.isUndefined else {
                    promise(.success(nil))
                    return
                }
                promise(.success(jsValue.toString()))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }
            
    private var offlineToken: Single<String?> {
        Single.deferred { [weak self] in
            guard WalletManager.shared.wallet.isInitialized() else {
                return .error(WalletError.notInitialized)
            }
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            guard let jsValue = self.jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(JSSetter.offlineToken) else {
                return Single.just(nil)
            }
            guard !jsValue.isNull, !jsValue.isUndefined else { return .just(nil) }
            return Single.just(jsValue.toString())
        }
        .subscribeOn(jsScheduler)
    }
    
    private var userIdPublisher: AnyPublisher<String?, WalletError> {
        let jsContextProvider = self.jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                guard WalletManager.shared.wallet.isInitialized() else {
                    promise(.failure(.notInitialized))
                    return
                }
                guard let jsValue = jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(JSSetter.userId) else {
                    promise(.success(nil))
                    return
                }
                guard !jsValue.isNull, !jsValue.isUndefined else {
                    promise(.success(nil))
                    return
                }
                promise(.success(jsValue.toString()))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }
    
    private var userId: Single<String?> {
        Single.deferred { [weak self] in
            guard WalletManager.shared.wallet.isInitialized() else {
                return .error(WalletError.notInitialized)
            }
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            guard let jsValue = self.jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(JSSetter.userId) else {
                return Single.just(nil)
            }
            guard !jsValue.isNull, !jsValue.isUndefined else { return .just(nil) }
            return Single.just(jsValue.toString())
        }
        .subscribeOn(jsScheduler)
    }
    
    private let settings: AppSettingsAPI
    private let jsScheduler: SerialDispatchQueueScheduler
    private let combineJSScheduler: DispatchQueue
    
    private unowned let jsContextProvider: JSContextProviderAPI
    
    // MARK: - Setup
    
    init(jsContextProvider: JSContextProviderAPI,
         settings: AppSettingsAPI,
         reactiveWallet: ReactiveWalletAPI,
         jsScheduler: SerialDispatchQueueScheduler = MainScheduler.instance,
         combineJSScheduler: DispatchQueue = DispatchQueue.main) {
        self.jsContextProvider = jsContextProvider
        self.settings = settings
        self.reactiveWallet = reactiveWallet
        self.jsScheduler = jsScheduler
        self.combineJSScheduler = combineJSScheduler
        super.init()
    }
    
    // MARK: - Wallet Setters
    
    func setPublisher(offlineTokenResponse: NabuOfflineTokenResponse) -> AnyPublisher<Void, CredentialWritingError> {
        let jsContextProvider = self.jsContextProvider
        return Deferred {
            Future { [jsContextProvider] promise in
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.failure(.offlineToken))
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsFailure as NSString
                )
                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.success(()))
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsSuccess as NSString
                )
                let userId = offlineTokenResponse.userId.escapedForJS()
                let offlineToken = offlineTokenResponse.token.escapedForJS()
                let script = String(format: JSSetter.updateUserCredentials, userId, offlineToken)
                jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)?.toString()
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }
    
    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                guard let self = self else {
                    observer(.error(ToolKitError.nullReference(Self.self)))
                    return Disposables.create()
                }
                
                self.jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        observer(.error(CredentialWritingError.offlineToken))
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsFailure as NSString
                )
                
                self.jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        observer(.completed)
                    },
                    forJsFunctionName: JSCallback.updateUserCredentialsSuccess as NSString
                )

                let userId = offlineTokenResponse.userId.escapedForJS()
                let offlineToken = offlineTokenResponse.token.escapedForJS()
                let script = String(format: JSSetter.updateUserCredentials, userId, offlineToken)
                
                self.jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)?.toString()
                
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
    
    /// Sets GUID
    func set(guid: String) -> Completable {
        perform { [weak self] in
            self?.settings.guid = guid
        }
    }

    /// Sets the session token
    func set(sessionToken: String) -> Completable {
        perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(sessionToken)
        }
    }
    
    /// Cleans the session token
    func cleanSessionToken() -> Completable {
        perform { [weak sessionTokenRelay] in
            sessionTokenRelay?.accept(nil)
        }
    }
    
    /// Sets Shared-Key
    func set(sharedKey: String) -> Completable {
        perform { [weak self] in
            self?.settings.sharedKey = sharedKey
        }
    }

    /// Sets Password
    func set(password: String) -> Completable {
        perform { [weak passwordRelay] in
            passwordRelay?.accept(password)
        }
    }
    
    func sync() -> Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                guard let self = self else {
                    observer(.error(PasswordRepositoryError.syncFailed))
                    return Disposables.create()
                }
                guard let password = self.passwordRelay.value else {
                    observer(.error(PasswordRepositoryError.unavailable))
                    return Disposables.create()
                }
                let script = String(format: JSSetter.Password.change, password)
                
                self.jsContextProvider.jsContext.invokeOnce(functionBlock: {
                    observer(.completed)
                }, forJsFunctionName: JSSetter.Password.success as NSString)
                
                self.jsContextProvider.jsContext.invokeOnce(functionBlock: {
                    observer(.error(PasswordRepositoryError.syncFailed))
                }, forJsFunctionName: JSSetter.Password.error as NSString)
                
                self.jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            return Disposables.create()
        }
    }
    
    /// Sets Authenticator Type
    func set(authenticatorType: AuthenticatorType) -> Completable {
        perform { [weak authenticatorTypeRelay] in
            authenticatorTypeRelay?.accept(authenticatorType)
        }
    }
    
    // MARK: - JS Setters
    
    /// Sets a boolean indicating whether the public keys should sync to the wallet
    func set(syncPubKeys: Bool) -> Completable {
        perform { [weak jsContextProvider] in
            let value = syncPubKeys ? "true" : "false"
            let script = String(format: JSSetter.syncPubKeys, value)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }
    
    /// Sets the language
    func set(language: String) -> Completable {
        perform { [weak jsContextProvider] in
            let escaped = language.escapedForJS()
            let script = String(format: JSSetter.language, escaped)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }
    
    /// Sets the wallet payload
    func set(payload: String) -> Completable {
        perform { [weak jsContextProvider] in
            let escaped = payload.escapedForJS()
            let script = String(format: JSSetter.payload, escaped)
            jsContextProvider?.jsContext.evaluateScriptCheckIsOnMainQueue(script)
        }
    }
    
    // MARK: - Accessors
    
    private func perform(_ operation: @escaping () -> Void) -> Completable {
        Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
    
    fileprivate func perform<E: Error>(_ operation: @escaping () -> Void) -> AnyPublisher<Void, E> {
        AnyPublisher<Void, E>
            .create { observer -> AnyCancellable in
                operation()
                observer.send(())
                observer.send(completion: .finished)
                return AnyCancellable {}
            }
            .subscribe(on: combineJSScheduler)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Legacy: PLEASE DONT USE THESE UNLESS YOU MUST HOOK LEGACY OBJ-C CODE

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacySessionToken: String? {
        get {
            sessionTokenRelay.value
        }
        set {
            sessionTokenRelay.accept(newValue)
        }
    }

    @available(*, deprecated, message: "Please do not use this unless you absolutely need direct access")
    @objc
    var legacyPassword: String? {
        get {
            passwordRelay.value
        }
        set {
            passwordRelay.accept(newValue)
        }
    }
}

// MARK: - SharedKeyRepositoryCombineAPI

extension WalletRepository {
    
    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKeyPublisher: AnyPublisher<String?, Never> {
        let settings = self.settings
        return Deferred {
            Future { [settings] promise in
                promise(.success(settings.sharedKey))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }
    
    /// Sets the shared key
    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.settings.sharedKey = sharedKey
        }
    }
}

// MARK: - GuidRepositoryCombineAPI

extension WalletRepository {
    
    var guidPublisher: AnyPublisher<String?, Never> {
        let settings = self.settings
        return Deferred {
            Future { [settings] promise in
                promise(.success(settings.guid))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    func setPublisher(guid: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.settings.guid = guid
        }
    }
}

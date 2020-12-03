//
//  PinScreenInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

/// Interactor for the pin. This component interacts with the Blockchain API and the local
/// pin data store. When the pin is updated, the pin is also stored on the keychain.
final class PinInteractor: PinInteracting {

    // MARK: - Properties
    
    private let pinClient: PinClientAPI
    private let maintenanceService: MaintenanceServicing
    private let credentialsProvider: WalletCredentialsProviding
    private let wallet: WalletProtocol
    private let appSettings: AppSettingsAuthenticating
    private let recorder: ErrorRecording
    private let loginService: PinLoginServiceAPI
    private let walletCryptoService: WalletCryptoServiceAPI

    private let disposeBag = DisposeBag()
    
    /// In case the user attempted to logout while the pin was being sent to the server
    /// the app needs to disragard any future response
    var hasLogoutAttempted = false
    
    // MARK: - Setup
    
    init(credentialsProvider: WalletCredentialsProviding = WalletManager.shared.legacyRepository,
         pinClient: PinClientAPI = PinClient(),
         maintenanceService: MaintenanceServicing = resolve(),
         wallet: WalletProtocol = WalletManager.shared.wallet,
         appSettings: AppSettingsAuthenticating = resolve(),
         recorder: Recording = CrashlyticsRecorder(),
         walletPayloadClient: WalletPayloadClientAPI = WalletPayloadClient(),
         walletRepository: WalletRepositoryAPI = resolve(),
         walletCryptoService: WalletCryptoServiceAPI = resolve()) {
        loginService = PinLoginService(
            settings: appSettings,
            service: WalletPayloadService(
                client: walletPayloadClient,
                repository: walletRepository
            ),
            walletRepository: walletRepository
        )
        self.credentialsProvider = credentialsProvider
        self.pinClient = pinClient
        self.maintenanceService = maintenanceService
        self.wallet = wallet
        self.appSettings = appSettings
        self.recorder = recorder
        self.walletCryptoService = walletCryptoService
    }
    
    // MARK: - API

    /// Creates a pin code in the remote pin store
    /// - Parameter payload: the pin payload
    /// - Returns: Completable indicating completion
    func create(using payload: PinPayload) -> Completable {
        maintenanceService.serverUnderMaintenanceMessage
            .flatMap(weak: self) { (self, message) -> Single<PinStoreResponse> in
                if let message = message { throw PinError.serverMaintenance(message: message) }
                return self.pinClient.create(pinPayload: payload)
            }
            .flatMapCompletable(weak: self, { (self, response) in
                self.handleCreatePinResponse(response: response, payload: payload)
            })
                .catchError { error in
                    throw PinError.map(from: error)
            }
            .observeOn(MainScheduler.instance)
    }
    
    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also fetch the WalletOptions to see if the server is under maintenance,
    /// then, handle updating the local pin store (i.e. the keychain),
    /// depending on the response for the remote pin store.
    /// - Parameter payload: the pin payload
    /// - Returns: Single warpping the pin decryption key
    func validate(using payload: PinPayload) -> Single<String> {
        maintenanceService.serverUnderMaintenanceMessage
            .flatMap(weak: self) { (self, message) -> Single<String> in
                if let message = message { throw PinError.serverMaintenance(message: message) }
                return self.pinClient.validate(pinPayload: payload)
                    .do(onSuccess: { [weak self] response in
                        try self?.updateCacheIfNeeded(response: response, pinPayload: payload)
                    })
                    .map { [weak self] response -> String in
                        guard let self = self else { throw PinError.unretainedSelf }
                        return try self.pinValidationStatus(from: response)
                    }
            }
            .catchError { error in
                throw PinError.map(from: error)
            }
            .observeOn(MainScheduler.instance)
    }
    
    func password(from pinDecryptionKey: String) -> Single<String> {
        loginService.password(from: pinDecryptionKey)
            .observeOn(MainScheduler.instance)
    }
    
    /// Keep the PIN value on the local pin store (i.e the keychain), for biometrics auth.
    /// - Parameter pin: the pin value
    func persist(pin: Pin) {
        pin.save(using: appSettings)
        appSettings.biometryEnabled = true
    }
    
    // MARK: - Accessors

    private func handleCreatePinResponse(response: PinStoreResponse, payload: PinPayload) -> Completable {
        Single<(pin: String, password: String)>
            .create(weak: self) { (self, observer) -> Disposable in
                // Wallet must have password at the stage
                guard let password = self.credentialsProvider.legacyPassword else {
                    let error = PinError.serverError(LocalizationConstants.Pin.cannotSaveInvalidWalletState)
                    self.recorder.error(error)
                    observer(.error(error))
                    return Disposables.create()
                }

                guard response.error == nil else {
                    self.recorder.error(PinError.serverError(""))
                    observer(.error(PinError.serverError(response.error!)))
                    return Disposables.create()
                }

                guard response.isSuccessful else {
                    let message = String(
                        format: LocalizationConstants.Errors.invalidStatusCodeReturned,
                        response.statusCode?.rawValue ?? -1
                    )
                    let error = PinError.serverError(message)
                    self.recorder.error(error)
                    observer(.error(error))
                    return Disposables.create()
                }

                guard let pinValue = payload.pinValue,
                    !payload.pinKey.isEmpty,
                    !pinValue.isEmpty else {
                        let error = PinError.serverError(LocalizationConstants.Pin.responseKeyOrValueLengthZero)
                        self.recorder.error(error)
                        observer(.error(error))
                        return Disposables.create()
                }
                observer(.success((pin: pinValue, password: password)))
                return Disposables.create()
            }
            .flatMap(weak: self) { (self, data) -> Single<(encryptedPinPassword: String, password: String)> in
                self.walletCryptoService
                    .encrypt(pair: KeyDataPair(key: data.pin, data: data.password),
                             pbkdf2Iterations: WalletCryptoPBKDF2Iterations.pinLogin)
                    .map { (encryptedPinPassword: $0, password: data.password) }
            }
            .flatMapCompletable(weak: self) { (self, data) -> Completable in
                // Once the pin has been created successfully, the wallet is not longer marked as new.
                self.wallet.isNew = false
                // Update the cache
                self.appSettings.encryptedPinPassword = data.encryptedPinPassword
                self.appSettings.pinKey = payload.pinKey
                self.appSettings.passwordPartHash = data.password.passwordPartHash
                try self.updateCacheIfNeeded(response: response, pinPayload: payload)
                return Completable.empty()
            }
    }

    /// Persists the pin if needed or deletes it according to the response code received from the backend
    private func updateCacheIfNeeded(response: PinStoreResponse,
                                     pinPayload: PinPayload) throws {
        // Make sure the user has not logout
        guard !hasLogoutAttempted else {
            throw PinError.receivedResponseWhileLoggedOut
        }
        
        guard let responseCode = response.statusCode else { return }
        switch responseCode {
        case .success where pinPayload.persistsLocally:
            // Optionally save the pin to the keychain to enable biometric authenticators
            persist(pin: pinPayload.pin!)
        case .deleted:
            // Clear pin from keychain if the user exceeded the number of retries when entering the pin.
            appSettings.pin = nil
            appSettings.biometryEnabled = false
        default:
            break
        }
    }
    
    // Returns the pin decryption key, or throws error if cannot
    private func pinValidationStatus(from response: PinStoreResponse) throws -> String {
        
        // First verify that the status code was received
        guard let statusCode = response.statusCode else {
            let error = PinError.serverError(LocalizationConstants.Errors.genericError)
            recorder.error(error)
            throw error
        }
        
        switch statusCode {
        case .deleted:
            throw PinError.tooManyAttempts
        case .incorrect:
            let message = response.error ?? LocalizationConstants.Pin.incorrect
            throw PinError.incorrectPin(message)
        case .success:
            guard let pinDecryptionKey = response.pinDecryptionValue, !pinDecryptionKey.isEmpty else {
                throw PinError.custom(LocalizationConstants.Errors.genericError)
            }
            return pinDecryptionKey
        }
    }
}

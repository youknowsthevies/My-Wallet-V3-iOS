//
//  NabuAuthenticationService.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import NetworkKit
import PlatformKit

/// Component in charge of authenticating the Nabu user.
final class NabuAuthenticationService: NabuAuthenticationServiceAPI {

    static let shared = NabuAuthenticationService()

    var fetchValue: Single<NabuSessionTokenResponse> {
        cachedValue.fetchValue
    }
    
    var value: Single<NabuSessionTokenResponse> {
        cachedValue.valueSingle
    }

    private var cachedValue: CachedValue<NabuSessionTokenResponse>!
    private let userCreationClient: UserCreationClientAPI
    private let authenticationClient: NabuAuthenticationClientAPI
    private let settingsService: SettingsServiceAPI
    private let walletRepository: WalletRepositoryAPI
    
    private let wallet: Wallet
    private let walletNabuSynchronizer: WalletNabuSynchronizerAPI
    
    // MARK: - Initialization

    init(authenticationClient: NabuAuthenticationClientAPI = NabuAuthenticationClient(),
         userCreationClient: UserCreationClientAPI = UserCreationClient(),
         settingsService: SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         wallet: Wallet = WalletManager.shared.wallet,
         reactiveWallet: ReactiveWalletAPI = ReactiveWallet(),
         walletRepository: WalletRepositoryAPI = WalletManager.shared.repository,
         walletNabuSynchronizer: WalletNabuSynchronizerAPI = WalletNabuSynchronizerService()) {
        self.authenticationClient = authenticationClient
        self.userCreationClient = userCreationClient
        self.walletRepository = walletRepository
        self.settingsService = settingsService
        self.wallet = wallet
        self.walletNabuSynchronizer = walletNabuSynchronizer
        
        let configuration = CachedValueConfiguration(
            identifier: "fetch-nabu-user-token",
            refreshType: .custom { [weak self] () -> Single<Bool> in
                guard let self = self else { return .just(false) }
                return self.getOrCreateNabuUserResponse()
                    .map(weak: self) { (self, userResponse) -> Bool in
                        let sessionToken = self.cachedValue?.legacyValue
                        
                        // Make sure cached session token is for this user
                        guard userResponse.userId == sessionToken?.userId else {
                            return true
                        }

                        // Make sure cached session token is not within 30 seconds of the expiration time.
                        // 30 seconds was added to account for server-phone time differences
                        guard let expiresAt = sessionToken?.expiresAt, Date() < expiresAt.addingTimeInterval(-30) else {
                            return true
                        }

                        return false
                    }
            },
            fetchPriority: .fetchAll,
            flushNotificationName: .logout
        )
        cachedValue = CachedValue<NabuSessionTokenResponse>(configuration: configuration)
        
        cachedValue
            .setFetch(weak: self) { (self) in
                reactiveWallet.waitUntilInitializedSingle
                    .flatMap(weak: self) { (self, _) in
                        self.getSessionToken()
                    }
            }
    }

    // Syncs the Nabu service with the wallet. Call this when something like Settings is updated on the client and Nabu needs to know about the new changes.
    func updateWalletInfo() -> Completable {
        value
            .flatMap(weak: self) { (self, token) in
                self.walletNabuSynchronizer.sync(token: token.token)
            }
            .asCompletable()
    }
    
    /// Returns a NabuSessionTokenResponse which is to be used for all KYC endpoints that
    /// require an authenticated KYC user. This function will handle creating a KYC user
    /// if needed, and it will also handle caching and refreshing the KYC session token
    /// as needed.
    ///
    /// Calling this end-point for the 1st time will create a KYC user which will then
    /// be persisted to the user's wallet metadata. The process of creating a KYC user
    /// requires a number of steps:
    ///   (1) a wallet JWT token (obtained by sending the wallet info such as GUID, sharedKey and API code)
    ///   (2) using the JWT token, create a Nabu user
    ///   (3) the created Nabu user is then persisted in the wallet metadata
    ///
    /// - Parameter requestNewToken: if a new token should be requested. Defaults to false so that a
    ///       session token is only requested if the cached token is expired.
    /// - Returns: a Single returning the sesion token
    private func getSessionToken() -> Single<NabuSessionTokenResponse> {
        getOrCreateNabuUserResponse()
            .flatMap(weak: self) { (self, response) -> Single<NabuSessionTokenResponse> in
                self.sessionToken(from: response)
            }
    }

    // MARK: - Private Methods

    /// Requests a new session token from Nabu followed by caching the response if successful
    private func sessionToken(from userResponse: CreateUserResponse) -> Single<NabuSessionTokenResponse> {
        let guid = walletRepository.guid
        let email = settingsService.valueSingle.map { $0.email }
  
        return Single
            .zip(guid, email)
            .flatMap(weak: self) { (self, payload) in
                guard let guid = payload.0 else {
                    throw MissingCredentialsError.guid
                }
                let email = payload.1
                
                return self.authenticationClient
                    .sessionToken(
                        for: guid,
                        userToken: userResponse.token,
                        userIdentifier: userResponse.userId,
                        deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                        email: email
                )
        }
    }

    /// Retrieves the user's Nabu user ID and API token from the wallet metadata if the Nabu user ID
    /// and api token had already been created. Otherwise, this method will create a new Nabu user ID
    /// and api token from the wallet GUID + email pair followed by updating the wallet metadata
    /// with the retrieved Nabu user ID.
    ///
    /// - Returns: a Single returning the user's Nabu api token
    private func getOrCreateNabuUserResponse() -> Single<CreateUserResponse> {
        guard let kycUserId = wallet.kycUserId(),
            let kycToken = wallet.kycLifetimeToken() else {
                return createAndSaveUserResponse()
        }
        return Single.just(CreateUserResponse(userId: kycUserId, token: kycToken))
    }

    /// Creates a KYC user ID and API token followed by updating the wallet metadata with
    /// the KYC user ID and API token.
    private func createAndSaveUserResponse() -> Single<CreateUserResponse> {
        return walletNabuSynchronizer.getSignedRetailToken()
            .flatMap(weak: self) { (self, tokenResponse) -> Single<CreateUserResponse> in
                self.createNabuUser(tokenResponse: tokenResponse)
            }
            .flatMap(weak: self) { (self, createUserResponse) -> Single<CreateUserResponse> in
                self.saveToWalletMetadata(createUserResponse: createUserResponse)
            }
    }
    
    private func createNabuUser(tokenResponse: SignedRetailTokenResponse) -> Single<CreateUserResponse> {
        guard let token = tokenResponse.token, tokenResponse.success else {
            return Single.error(NabuAuthenticationError.invalidSignedRetailToken)
        }
        return userCreationClient.createUser(for: token)
    }

    private func saveToWalletMetadata(createUserResponse: CreateUserResponse) -> Single<CreateUserResponse> {
        return Single.create(subscribe: { [unowned self] observer -> Disposable in
            self.wallet.updateKYCUserCredentials(
                withUserId: createUserResponse.userId,
                lifetimeToken: createUserResponse.token,
                success: { _ in
                observer(.success(createUserResponse))
            }, error: { errorText in
                Logger.shared.error("Failed to update wallet metadata: \(errorText ?? "")")
                observer(.error(NSError(domain: "FailedToUpdateWalletMetadata", code: 0, userInfo: nil)))
            })
            return Disposables.create()
        })
    }
}

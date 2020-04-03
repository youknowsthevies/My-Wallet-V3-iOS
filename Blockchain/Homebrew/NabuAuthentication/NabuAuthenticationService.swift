//
//  NabuAuthenticationService.swift
//  Blockchain
//
//  Created by kevinwu on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
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
    private let wallet: Wallet
    private let walletManager: WalletManager
    private let walletNabuSynchronizer: WalletNabuSynchronizerAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let supportedPairsService: SimpleBuySupportedPairsServiceAPI
    
    // MARK: - Initialization

    init(
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
        supportedPairsService: SimpleBuySupportedPairsServiceAPI = SimpleBuySupportedPairsService(client: SimpleBuyClient()),
        walletManager: WalletManager = .shared,
        wallet: Wallet = WalletManager.shared.wallet,
        reactiveWallet: ReactiveWalletAPI = ReactiveWallet(),
        walletNabuSynchronizer: WalletNabuSynchronizerAPI = WalletNabuSynchronizerService()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.supportedPairsService = supportedPairsService
        self.walletManager = walletManager
        self.wallet = wallet
        self.walletNabuSynchronizer = walletNabuSynchronizer
        
        let configuration = CachedValueConfiguration(
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
            }
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
                self.requestNewSessionToken(from: response)
            }
    }

    // MARK: - Private Methods

    /// Requests a new session token from Nabu followed by caching the response if successful
    private func requestNewSessionToken(from userResponse: NabuCreateUserResponse) -> Single<NabuSessionTokenResponse> {
        guard let guid = self.walletManager.legacyRepository.legacyGuid else {
            Logger.shared.warning("Cannot get Nabu authentication token, guid is nil.")
            return Single.error(WalletError.notInitialized)
        }

        guard let email = self.wallet.getEmail() else {
            Logger.shared.warning("Cannot get Nabu authentication token, email is nil.")
            return Single.error(WalletError.notInitialized)
        }

        let headers: [String: String] = [
            HttpHeaderField.authorization: userResponse.token,
            HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
            HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp,
            HttpHeaderField.deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            HttpHeaderField.walletGuid: guid,
            HttpHeaderField.walletEmail: email
        ]
        
        Logger.shared.debug("Sending Session Token Request")
        
        return KYCNetworkRequest.request(
            post: .sessionToken(userId: userResponse.userId),
            parameters: [:],
            headers: headers,
            type: NabuSessionTokenResponse.self
        )
    }

    /// Retrieves the user's Nabu user ID and API token from the wallet metadata if the Nabu user ID
    /// and api token had already been created. Otherwise, this method will create a new Nabu user ID
    /// and api token from the wallet GUID + email pair followed by updating the wallet metadata
    /// with the retrieved Nabu user ID.
    ///
    /// - Returns: a Single returning the user's Nabu api token
    private func getOrCreateNabuUserResponse() -> Single<NabuCreateUserResponse> {
        guard let kycUserId = wallet.kycUserId(),
            let kycToken = wallet.kycLifetimeToken() else {
                return createAndSaveUserResponse()
        }
        return Single.just(NabuCreateUserResponse(userId: kycUserId, token: kycToken))
    }

    /// Creates a KYC user ID and API token followed by updating the wallet metadata with
    /// the KYC user ID and API token.
    private func createAndSaveUserResponse() -> Single<NabuCreateUserResponse> {
        return walletNabuSynchronizer.getSignedRetailToken()
            .flatMap(weak: self) { (self, tokenResponse) -> Single<NabuCreateUserResponse> in
                self.createNabuUser(tokenResponse: tokenResponse)
            }
            .flatMap(weak: self) { (self, createUserResponse) -> Single<NabuCreateUserResponse> in
                self.saveToWalletMetadata(createUserResponse: createUserResponse)
            }
    }
    
    /// TODO: Fix this as part of IOS-2875 Part II
    /// For now we are using the fact that the user's currency is supported to determine
    /// if the `SIMPLE_BUY` tag should be added to the user or not.
    private func createNabuUser(tokenResponse: SignedRetailTokenResponse) -> Single<NabuCreateUserResponse> {
        guard let token = tokenResponse.token, tokenResponse.success else {
            return Single.error(NabuAuthenticationError.invalidSignedRetailToken)
        }
        
        return fiatCurrencyService.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<KYCNetworkRequest.KYCEndpoints.POST.UserType> in
                self.supportedPairsService.fetchPairs(for: .only(fiatCurrency: fiatCurrency))
                    .map { pairsResponse in
                        guard pairsResponse.pairs.count > 0 else {
                            return .regular
                        }
                        return .simpleBuy(fiatCurrency: fiatCurrency.code)
                    }
            }
            .flatMap { userType -> Single<NabuCreateUserResponse> in
                KYCNetworkRequest.request(
                    post: .createUser(userType),
                    parameters: ["jwt": token],
                    headers: nil,
                    type: NabuCreateUserResponse.self
                )
            }
    }

    private func saveToWalletMetadata(createUserResponse: NabuCreateUserResponse) -> Single<NabuCreateUserResponse> {
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

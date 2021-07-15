// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public final class WalletPayloadService: WalletPayloadServiceAPI {

    // MARK: - Types

    public typealias WalletRepositoryAPI = GuidRepositoryAPI &
        SessionTokenRepositoryAPI &
        SharedKeyRepositoryAPI &
        LanguageRepositoryAPI &
        SyncPubKeysRepositoryAPI &
        AuthenticatorRepositoryAPI &
        PayloadRepositoryAPI

    // MARK: - Properties

    private let client: WalletPayloadClientAPI
    private let repository: WalletRepositoryAPI

    // MARK: - Setup

    public init(client: WalletPayloadClientAPI = WalletPayloadClient(), repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    // MARK: - API

    public func requestUsingSessionToken() -> Single<WalletAuthenticatorType> {
        Single
            .zip(repository.guid, repository.sessionToken)
            .flatMap(weak: self) { (self, credentials) -> Single<WalletAuthenticatorType> in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sessionToken = credentials.1 else {
                    throw MissingCredentialsError.sessionToken
                }
                return self.request(guid: guid, sessionToken: sessionToken)
            }
    }

    public func requestUsingSharedKey() -> Completable {
        Single
            .zip(repository.guid, repository.sharedKey)
            .flatMapCompletable(weak: self) { (self, credentials) -> Completable in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sharedKey = credentials.1 else {
                    throw MissingCredentialsError.sharedKey
                }
                return self.request(guid: guid, sharedKey: sharedKey)
            }
    }

    /// Performs the request using given parameters: guid and shared-key
    public func request(guid: String, sharedKey: String) -> Completable {
        client
            .payload(guid: guid, identifier: .sharedKey(sharedKey))
            .flatMap(weak: self) { (self, response) -> Single<WalletPayloadClient.ClientResponse> in
                self.cacheWalletData(from: response)
            }
            .asCompletable()
    }

    /// Performs the request using cached GUID and session-token
    private func request(guid: String, sessionToken: String) -> Single<WalletAuthenticatorType> {
        client
            .payload(guid: guid, identifier: .sessionToken(sessionToken))
            .flatMap(weak: self) { (self, response) -> Single<WalletPayloadClient.ClientResponse> in
                self.cacheWalletData(from: response)
            }
            .map(weak: self) { (_, response) -> WalletAuthenticatorType in
                guard let type = WalletAuthenticatorType(rawValue: response.authType) else {
                    throw WalletPayloadServiceError.unsupported2FAType
                }
                return type
            }
            .catchError { error -> Single<WalletAuthenticatorType> in
                switch error {
                case WalletPayloadClient.ClientError.emailAuthorizationRequired:
                    return .just(.email)
                case WalletPayloadClient.ClientError.accountLocked:
                    throw WalletPayloadServiceError.accountLocked
                case WalletPayloadClient.ClientError.message(let message):
                    throw WalletPayloadServiceError.message(message)
                default:
                    throw error
                }
            }
    }

    /// Used to cache the client response
    private func cacheWalletData(from clientResponse: WalletPayloadClient.ClientResponse) -> Single<WalletPayloadClient.ClientResponse> {
        Completable
            .zip(
                repository.set(guid: clientResponse.guid),
                repository.set(language: clientResponse.language),
                repository.set(syncPubKeys: clientResponse.shouldSyncPubkeys)
            )
            .flatMap(weak: self) { (self) -> Completable in
                guard let type = WalletAuthenticatorType(rawValue: clientResponse.authType) else {
                    throw WalletPayloadServiceError.unsupported2FAType
                }
                return self.repository.set(authenticatorType: type)
            }
            .flatMap(weak: self) { (self) -> Completable in
                if let rawPayload = clientResponse.payload?.stringRepresentation, !rawPayload.isEmpty {
                    return self.repository.set(payload: rawPayload)
                }
                return .empty()
            }
            .andThen(Single.just(clientResponse))
    }
}

// MARK: WalletPayloadServiceCombineAPI

extension WalletPayloadService {

    public func requestUsingSessionTokenPublisher() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let requestPublisher = self.requestPublisher(guid:sessionToken:)
        return repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .setFailureType(to: WalletPayloadServiceError.self)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), WalletPayloadServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { credentials -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                requestPublisher(credentials.guid, credentials.sessionToken)
            }
            .eraseToAnyPublisher()
    }

    public func requestUsingSharedKeyPublisher() -> AnyPublisher<Void, WalletPayloadServiceError> {
        let requestPublisher = self.requestPublisher(guid:sharedKey:)
        return repository.guidPublisher
            .zip(repository.sharedKeyPublisher)
            .setFailureType(to: WalletPayloadServiceError.self)
            .flatMap { credentials -> AnyPublisher<(guid: String, sharedKey: String), WalletPayloadServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sharedKey = credentials.1 else {
                    return .failure(.missingCredentials(.sharedKey))
                }
                return .just((guid, sharedKey))
            }
            .flatMap { credentials -> AnyPublisher<Void, WalletPayloadServiceError> in
                requestPublisher(credentials.guid, credentials.sharedKey)
            }
            .eraseToAnyPublisher()
    }

    public func requestPublisher(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError> {
        let cacheWalletDataPublisher = self.cacheWalletDataPublisher(from:)
        return client
            .payloadPublisher(guid: guid, identifier: .sharedKey(sharedKey))
            .mapError(WalletPayloadServiceError.init)
            .flatMap { response -> AnyPublisher<Void, WalletPayloadServiceError> in
                cacheWalletDataPublisher(response)
                    .mapToVoid()
            }
            .eraseToAnyPublisher()
    }

    public func requestPublisher(guid: String, sessionToken: String) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let cacheWalletDataPublisher = self.cacheWalletDataPublisher(from:)
        return client
            .payloadPublisher(guid: guid, identifier: .sessionToken(sessionToken))
            .mapError(WalletPayloadServiceError.init)
            .flatMap { response -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError> in
                cacheWalletDataPublisher(response)
            }
            .flatMap { response -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: response.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return .just(type)
            }
            .catch { error -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                switch error {
                case .emailAuthorizationRequired:
                    return .just(.email)
                default:
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    public func cacheWalletDataPublisher(
        from clientResponse: WalletPayloadClient.ClientResponse
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError>  {
        repository.setPublisher(guid: clientResponse.guid)
            .zip(repository.setPublisher(language: clientResponse.language))
            .zip(repository.setPublisher(syncPubKeys: clientResponse.shouldSyncPubkeys))
            .setFailureType(to: WalletPayloadServiceError.self)
            .flatMap { [repository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: clientResponse.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return repository.setPublisher(authenticatorType: type)
                    .setFailureType(to: WalletPayloadServiceError.self)
                    .eraseToAnyPublisher()
            }
            .flatMap { [repository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                if let rawPayload = clientResponse.payload?.stringRepresentation, !rawPayload.isEmpty {
                    return repository.setPublisher(payload: rawPayload)
                        .setFailureType(to: WalletPayloadServiceError.self)
                        .eraseToAnyPublisher()
                }
                return .just(())
            }
            .flatMap { _ -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError> in
                .just(clientResponse)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - WalletPayloadServiceError

extension WalletPayloadServiceError {
    init(clientError: WalletPayloadClient.ClientError) {
        switch clientError {
        case .missingPayload:
            self = .missingPayload
        case .missingGuid:
            self = .missingCredentials(.guid)
        case .emailAuthorizationRequired:
            self = .emailAuthorizationRequired
        case .accountLocked:
            self = .accountLocked
        case let .message(message):
            self = .message(message)
        case .unknown:
            self = .unknown
        }
    }
}

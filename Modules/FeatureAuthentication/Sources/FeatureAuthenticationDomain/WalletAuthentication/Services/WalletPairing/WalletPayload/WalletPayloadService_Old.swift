// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import WalletPayloadKit

public final class WalletPayloadServiceOld: WalletPayloadServiceAPI {
    // MARK: - Types

    typealias WalletRepositoryAPI = GuidRepositoryAPI &
        SessionTokenRepositoryAPI &
        SharedKeyRepositoryAPI &
        LanguageRepositoryAPI &
        SyncPubKeysRepositoryAPI &
        AuthenticatorRepositoryAPI &
        PayloadRepositoryAPI

    // MARK: - Properties

    private let repository: WalletPayloadRepositoryAPI
    private let walletRepository: WalletRepositoryAPI

    // MARK: - Setup

    init(
        repository: WalletPayloadRepositoryAPI,
        walletRepository: WalletRepositoryAPI
    ) {
        self.repository = repository
        self.walletRepository = walletRepository
    }

    public func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let request = request(guid:sessionToken:)
        return walletRepository
            .guid
            .zip(walletRepository.sessionToken)
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
                request(credentials.guid, credentials.sessionToken)
            }
            .eraseToAnyPublisher()
    }

    public func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        let request = request(guid:sharedKey:)
        return walletRepository
            .guid
            .zip(walletRepository.sharedKey)
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
                request(credentials.guid, credentials.sharedKey)
            }
            .eraseToAnyPublisher()
    }

    public func request(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return repository
            .payload(guid: guid, identifier: .sharedKey(sharedKey))
            .flatMap { payload -> AnyPublisher<Void, WalletPayloadServiceError> in
                cacheWalletData(payload)
                    .mapToVoid()
            }
            .eraseToAnyPublisher()
    }

    public func request(
        guid: String,
        sessionToken: String
    ) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return repository
            .payload(guid: guid, identifier: .sessionToken(sessionToken))
            .flatMap { payload -> AnyPublisher<WalletPayload, WalletPayloadServiceError> in
                cacheWalletData(payload)
            }
            .flatMap { payload -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: payload.authType) else {
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

    func cacheWalletData(
        from payload: WalletPayload
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError> {
        walletRepository.set(guid: payload.guid)
            .zip(walletRepository.set(language: payload.language))
            .zip(walletRepository.set(syncPubKeys: payload.shouldSyncPubKeys))
            .flatMap { [walletRepository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: payload.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return walletRepository.set(authenticatorType: type)
                    .mapError()
            }
            .flatMap { [walletRepository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                if let rawPayload = payload.payloadWrapper?.stringRepresentation, !rawPayload.isEmpty {
                    return walletRepository.set(payload: rawPayload)
                        .mapError()
                }
                return .just(())
            }
            .flatMap { _ -> AnyPublisher<WalletPayload, WalletPayloadServiceError> in
                .just(payload)
            }
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import WalletPayloadKit

public final class WalletPayloadServiceNew: WalletPayloadServiceAPI {

    // MARK: - Properties

    private let repository: WalletPayloadRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    // MARK: - Setup

    init(
        repository: WalletPayloadRepositoryAPI,
        walletRepo: WalletRepoAPI,
        credentialsRepository: CredentialsRepositoryAPI
    ) {
        self.repository = repository
        self.walletRepo = walletRepo
        self.credentialsRepository = credentialsRepository
    }

    public func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let request = request(guid:sessionToken:)
        return walletRepo
            .credentials
            .first()
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), WalletPayloadServiceError> in
                guard !credentials.guid.isEmpty else {
                    return .failure(.missingCredentials(.guid))
                }
                guard !credentials.sessionToken.isEmpty else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((credentials.guid, credentials.sessionToken))
            }
            .flatMap { credentials -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                request(credentials.guid, credentials.sessionToken)
            }
            .eraseToAnyPublisher()
    }

    public func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        let request = request(guid:sharedKey:)
        return credentialsRepository
            .credentials
            .first()
            .mapError(WalletPayloadServiceError.missingCredentials)
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

    private func cacheWalletData(
        from payload: WalletPayload
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError> {
        guard let authenticatorType = WalletAuthenticatorType(rawValue: payload.authType) else {
            return .failure(.unsupported2FAType)
        }
        guard let rawPayload = payload.payload else {
            return .failure(.missingPayload)
        }
        return walletRepo
            .set(keyPath: \.credentials.guid, value: payload.guid)
            .set(keyPath: \.properties.language, value: payload.language)
            .set(keyPath: \.properties.syncPubKeys, value: payload.shouldSyncPubKeys)
            .set(keyPath: \.encryptedPayload, value: rawPayload)
            .set(keyPath: \.properties.authenticatorType, value: authenticatorType)
            .get()
            .map { _ in payload }
            .first()
            .mapError()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

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

    private let walletRepo: WalletRepo

    private let nativeWalletEnabledUseImpl: NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI>
    private let oldImpl: WalletPayloadServiceOld
    private let newImpl: WalletPayloadServiceNew

    // MARK: - Setup

    public init(
        client: WalletPayloadClientAPI = WalletPayloadClient(),
        repository: WalletRepositoryAPI,
        walletRepo: WalletRepo,
        nativeWalletEnabledUse: @escaping NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI>
    ) {
        self.client = client
        self.repository = repository
        self.walletRepo = walletRepo

        nativeWalletEnabledUseImpl = nativeWalletEnabledUse

        oldImpl = WalletPayloadServiceOld(
            client: client,
            repository: repository
        )

        newImpl = WalletPayloadServiceNew(
            client: client,
            walletRepo: walletRepo
        )
    }

    // MARK: - API

    public func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        nativeWalletEnabledUseImpl(
            oldImpl,
            newImpl
        )
        .flatMap { either -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
            either.fold(
                left: { old in old.requestUsingSessionToken() },
                right: { new in new.requestUsingSessionToken() }
            )
        }
        .eraseToAnyPublisher()
    }

    public func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        nativeWalletEnabledUseImpl(
            oldImpl,
            newImpl
        )
        .flatMap { either -> AnyPublisher<Void, WalletPayloadServiceError> in
            either.fold(
                left: { old in old.requestUsingSharedKey() },
                right: { new in new.requestUsingSharedKey() }
            )
        }
        .eraseToAnyPublisher()
    }

    public func request(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, WalletPayloadServiceError> {
        nativeWalletEnabledUseImpl(
            oldImpl,
            newImpl
        )
        .flatMap { either -> AnyPublisher<Void, WalletPayloadServiceError> in
            either.fold(
                left: { old in old.request(guid: guid, sharedKey: sharedKey) },
                right: { new in new.request(guid: guid, sharedKey: sharedKey) }
            )
        }
        .eraseToAnyPublisher()
    }

    public func request(
        guid: String,
        sessionToken: String
    ) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        nativeWalletEnabledUseImpl(
            oldImpl,
            newImpl
        )
        .flatMap { either -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
            either.fold(
                left: { old in old.request(guid: guid, sessionToken: sessionToken) },
                right: { new in new.request(guid: guid, sessionToken: sessionToken) }
            )
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
        case .message(let message):
            self = .message(message)
        case .unknown:
            self = .unknown
        }
    }
}

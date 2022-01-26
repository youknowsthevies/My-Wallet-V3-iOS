// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
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

    private let repository: WalletPayloadRepositoryAPI
    private let walletRepository: WalletRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let nativeWalletEnabledUseImpl: NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI>
    private let oldImpl: WalletPayloadServiceOld
    private let newImpl: WalletPayloadServiceNew

    // MARK: - Setup

    public init(
        repository: WalletPayloadRepositoryAPI,
        walletRepository: WalletRepositoryAPI,
        walletRepo: WalletRepoAPI,
        nativeWalletEnabledUse: @escaping NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI>
    ) {
        self.repository = repository
        self.walletRepository = walletRepository
        self.walletRepo = walletRepo
        nativeWalletEnabledUseImpl = nativeWalletEnabledUse
        oldImpl = WalletPayloadServiceOld(
            repository: repository,
            walletRepository: walletRepository
        )
        newImpl = WalletPayloadServiceNew(
            repository: repository,
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

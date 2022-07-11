// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import ToolKit
import WalletPayloadKit

public enum WalletFetcherServiceError: LocalizedError, Equatable {
    case walletError(WalletError)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .walletError(let error):
            return error.errorDescription
        case .unknown:
            return LocalizationConstants.Errors.genericError
        }
    }
}

public struct WalletFetcherService {
    /// Fetches a wallet using the given details
    public var fetchWallet: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String
    ) -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>

    /// Fetches a wallet using guid/sharedKey and then stores the given `NabuOfflineToken`
    public var fetchWalletAfterAccountRecovery: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String,
        _ offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>
}

extension WalletFetcherService {

    public static func live(
        walletManager: WalletManagerAPI,
        accountRecoveryService: AccountRecoveryServiceAPI,
        walletFetcher: WalletFetcherAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        Self(
            fetchWallet: { guid, sharedKey, password
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                nativeWalletEnabled()
                    .flatMap { isEnabled
                        -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                        guard isEnabled else {
                            return legacyLoadWallet(
                                walletManager: walletManager,
                                guid: guid,
                                sharedKey: sharedKey,
                                password: password
                            )
                            .mapError { _ in WalletFetcherServiceError.unknown }
                            .map { _ in .left(.noValue) }
                            .eraseToAnyPublisher()
                        }
                        return nativeLoadWallet(
                            walletFetcher: walletFetcher,
                            guid: guid,
                            sharedKey: sharedKey,
                            password: password
                        )
                        .map { value -> Either<EmptyValue, WalletFetchedContext> in
                            .right(value)
                        }
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            },
            fetchWalletAfterAccountRecovery: { guid, sharedKey, password, offlineToken
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                nativeWalletEnabled()
                    .flatMap { isEnabled
                        -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                        guard isEnabled else {
                            return legacyLoadWallet(
                                walletManager: walletManager,
                                guid: guid,
                                sharedKey: sharedKey,
                                password: password
                            )
                            .mapError { _ in WalletFetcherServiceError.unknown }
                            .map { _ in .left(.noValue) }
                            .eraseToAnyPublisher()
                        }
                        return nativeLoadWallet(
                            walletFetcher: walletFetcher,
                            guid: guid,
                            sharedKey: sharedKey,
                            password: password
                        )
                        .map { value in .right(value) }
                        .eraseToAnyPublisher()
                    }
                    .flatMap { value
                        -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                        accountRecoveryService
                            .store(offlineToken: offlineToken)
                            .map { _ in value }
                            .mapError { _ in WalletFetcherServiceError.unknown }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            fetchWallet: { _, _, _
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                .empty()
            },
            fetchWalletAfterAccountRecovery: { _, _, _, _
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                .empty()
            }
        )
    }
}

func legacyLoadWallet(
    walletManager: WalletManagerAPI,
    guid: String,
    sharedKey: String,
    password: String
) -> AnyPublisher<EmptyValue, WalletFetcherServiceError> {
    walletManager.forgetWallet()
    walletManager.load(
        with: guid,
        sharedKey: sharedKey,
        password: password
    )
    walletManager.markWalletAsNew()
    return walletManager.didCompleteAuthentication
        .flatMap { result -> AnyPublisher<EmptyValue, WalletFetcherServiceError> in
            switch result {
            case .success:
                return .just(.noValue)
            case .failure:
                return .failure(.unknown)
            }
        }
        .eraseToAnyPublisher()
}

func nativeLoadWallet(
    walletFetcher: WalletFetcherAPI,
    guid: String,
    sharedKey: String,
    password: String
) -> AnyPublisher<WalletFetchedContext, WalletFetcherServiceError> {
    walletFetcher.fetch(guid: guid, sharedKey: sharedKey, password: password)
        .mapError(WalletFetcherServiceError.walletError)
        .eraseToAnyPublisher()
}

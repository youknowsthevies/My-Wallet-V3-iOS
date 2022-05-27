// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletFetcherService {
    /// Fetches a wallet using the given details
    public var fetchWallet: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String
    ) -> AnyPublisher<EmptyValue, WalletError>

    /// Fetches a wallet using guid/sharedKey and then stores the given `NabuOfflineToken`
    public var fetchWalletAfterAccountRecovery: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String,
        _ offlineToken: NabuOfflineToken
    ) -> AnyPublisher<EmptyValue, WalletError>
}

extension WalletFetcherService {

    public static func live(
        walletManager: WalletManagerAPI,
        accountRecoveryService: AccountRecoveryServiceAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        Self(
            fetchWallet: { guid, sharedKey, password -> AnyPublisher<EmptyValue, WalletError> in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<EmptyValue, WalletError> in
                        guard isEnabled else {
                            return legacyLoadWallet(
                                walletManager: walletManager,
                                guid: guid,
                                sharedKey: sharedKey,
                                password: password
                            )
                        }
                        fatalError("wallet loading not supported natively yet")
                    }
                    .eraseToAnyPublisher()
            },
            fetchWalletAfterAccountRecovery: { guid, sharedKey, password, offlineToken -> AnyPublisher<EmptyValue, WalletError> in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<EmptyValue, WalletError> in
                        guard isEnabled else {
                            return legacyLoadWallet(
                                walletManager: walletManager,
                                guid: guid,
                                sharedKey: sharedKey,
                                password: password
                            )
                            .flatMap { _ -> AnyPublisher<EmptyValue, WalletError> in
                                accountRecoveryService
                                    .store(offlineToken: offlineToken)
                                    .map { _ in EmptyValue.noValue }
                                    .mapError { _ in WalletError.unknown }
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                        }
                        fatalError("wallet loading not supported natively yet")
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            fetchWallet: { _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
                .empty()
            },
            fetchWalletAfterAccountRecovery: { _, _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
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
) -> AnyPublisher<EmptyValue, WalletError> {
    walletManager.forgetWallet()
    walletManager.load(
        with: guid,
        sharedKey: sharedKey,
        password: password
    )
    walletManager.markWalletAsNew()
    return walletManager.didCompleteAuthentication
        .flatMap { result -> AnyPublisher<EmptyValue, WalletError> in
            switch result {
            case .success:
                return .just(.noValue)
            case .failure:
                return .failure(.initialization(.unknown))
            }
        }
        .eraseToAnyPublisher()
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletFetcherService {
    /// Creates a new wallet using the given details
    public var fetchWallet: (
        _ guid: String,
        _ sharedKey: String,
        _ password: String
    ) -> AnyPublisher<EmptyValue, WalletError>
}

extension WalletFetcherService {

    public static func live(
        walletManager: WalletManagerAPI,
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
                        fatalError("wallet loading not support natively yet")
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            fetchWallet: { _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
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
    return .just(.noValue)
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletCreationService {
    public var createWallet: (
        _ email: String,
        _ password: String,
        _ accountName: String,
        _ language: String
    ) -> AnyPublisher<WalletCreation, WalletCreateError>
}

extension WalletCreationService {

    public static func live(
        walletManager: WalletManagerAPI,
        walletCreator: WalletCreatorAPI,
        nativeWalletCreationEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        let walletManager = walletManager
        let walletCreator = walletCreator
        let nativeWalletCreationEnabled = nativeWalletCreationEnabled
        return Self(
            createWallet: { email, password, accountName, language -> AnyPublisher<WalletCreation, WalletCreateError> in
                nativeWalletCreationEnabled()
                    .flatMap { isEnabled -> AnyPublisher<WalletCreation, WalletCreateError> in
                        guard isEnabled else {
                            return legacyCreation(
                                walletManager: walletManager,
                                email: email,
                                password: password
                            )
                            .mapError(WalletCreateError.legacyError)
                            .eraseToAnyPublisher()
                        }
                        return walletCreator.createWallet(
                            email: email,
                            password: password,
                            accountName: accountName,
                            language: language
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreation, WalletCreateError> in
                .empty()
            }
        )
    }
}

// MARK: - Legacy Creation

func legacyCreation(
    walletManager: WalletManagerAPI,
    email: String,
    password: String
) -> AnyPublisher<WalletCreation, WalletCreationError> {
    walletManager.loadWalletJS()
    walletManager.newWallet(password: password, email: email)

    return walletManager.didCreateNewAccount
        .flatMap { [walletManager] result -> AnyPublisher<WalletCreation, WalletCreationError> in
            switch result {
            case .success(let value):
                return legacyLoadWallet(
                    walletManager: walletManager,
                    context: value
                )
            case .failure(let error):
                return .failure(error)
            }
        }
        .eraseToAnyPublisher()
}

func legacyLoadWallet(
    walletManager: WalletManagerAPI,
    context: WalletCreation
) -> AnyPublisher<WalletCreation, WalletCreationError> {
    walletManager.forgetWallet()
    walletManager.load(
        with: context.guid,
        sharedKey: context.sharedKey,
        password: context.password
    )
    return .just(context)
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletCreatedContext: Equatable {
    public let guid: String
    public let sharedKey: String
    public let password: String
}

public typealias CreateWalletMethod = (
    _ email: String,
    _ password: String,
    _ accountName: String
) -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError>

public typealias SetResidentialInfoMethod = (
    _ country: String,
    _ state: String?
) -> AnyPublisher<Void, Never>

public struct WalletCreationService {
    /// Creates a new wallet using the given details
    public var createWallet: CreateWalletMethod
    /// Sets the residential info as part of account creation
    public var setResidentialInfo: SetResidentialInfoMethod
}

extension WalletCreationService {

    public static func live(
        walletManager: WalletManagerAPI,
        walletCreator: WalletCreatorAPI,
        nabuRepository: NabuRepositoryAPI,
        nativeWalletCreationEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        let walletManager = walletManager
        let walletCreator = walletCreator
        let nativeWalletCreationEnabled = nativeWalletCreationEnabled
        return Self(
            createWallet: { email, password, accountName -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                nativeWalletCreationEnabled()
                    .flatMap { isEnabled -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                        guard isEnabled else {
                            return legacyCreation(
                                walletManager: walletManager,
                                email: email,
                                password: password
                            )
                            .eraseToAnyPublisher()
                        }
                        return walletCreator.createWallet(
                            email: email,
                            password: password,
                            accountName: accountName,
                            language: "en"
                        )
                        .mapError(WalletCreationServiceError.creationFailure)
                        .map(WalletCreatedContext.from(model:))
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            },
            setResidentialInfo: { country, state -> AnyPublisher<Void, Never> in
                // we fire the request but we ignore the error,
                // even if this fails the user will still have to submit their details
                // as part of the KYC flow
                nabuRepository.setInitialResidentialInfo(
                    country: country,
                    state: state
                )
                .ignoreFailure()
            }
        )
    }

    public static var noop: Self {
        Self(
            createWallet: { _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .empty()
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Never> in
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
) -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> {
    walletManager.loadWalletJS()
    walletManager.newWallet(password: password, email: email)

    return walletManager.didCreateNewAccount
        .flatMap { result -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
            switch result {
            case .success(let value):
                return .just(
                    WalletCreatedContext.from(model: value)
                )
                .eraseToAnyPublisher()
            case .failure(let error):
                return .failure(WalletCreationServiceError.creationFailure(.legacyError(error)))
            }
        }
        .eraseToAnyPublisher()
}

extension WalletCreatedContext {
    static func from(model: WalletCreation) -> Self {
        WalletCreatedContext(
            guid: model.guid,
            sharedKey: model.sharedKey,
            password: model.password
        )
    }
}

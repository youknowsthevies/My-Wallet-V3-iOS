// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class AuthenticatorRepository: AuthenticatorRepositoryAPI {
    let authenticatorType: Single<WalletAuthenticatorType>
    let authenticatorTypePublisher: AnyPublisher<WalletAuthenticatorType, Never>

    // This is set to the older WalletRepository API, soon to be removed
    private let walletRepository: WalletRepositoryAPI
    private let walletRepo: WalletRepo
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    init(
        walletRepository: WalletRepositoryAPI,
        walletRepo: WalletRepo,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletRepository = walletRepository
        self.walletRepo = walletRepo
        self.nativeWalletEnabled = nativeWalletEnabled

        authenticatorType = nativeWalletEnabled()
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap { isEnabled -> Single<WalletAuthenticatorType> in
                guard isEnabled else {
                    return walletRepository.authenticatorType
                }
                return .just(walletRepo.properties.authenticatorType)
            }

        authenticatorTypePublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<WalletAuthenticatorType, Never> in
                guard isEnabled else {
                    return walletRepository.authenticatorTypePublisher
                }
                return walletRepo.map(\.properties.authenticatorType)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(authenticatorType: WalletAuthenticatorType) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(authenticatorType: authenticatorType)
                }
                return walletRepo.set(keyPath: \.properties.authenticatorType, value: authenticatorType)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepo, walletRepository] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(authenticatorType: authenticatorType)
                }
                return walletRepo.set(keyPath: \.properties.authenticatorType, value: authenticatorType)
                    .mapToVoid()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

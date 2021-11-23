// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class PasswordRepository: PasswordRepositoryAPI {
    let password: Single<String?>
    let hasPasswordPublisher: AnyPublisher<Bool, Never>
    let passwordPublisher: AnyPublisher<String?, Never>

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

        password = nativeWalletEnabled()
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap { isEnabled -> Single<String?> in
                guard isEnabled else {
                    return walletRepository.password
                }
                let guidOrNil = walletRepo.credentials.password.isEmpty ? nil : walletRepo.credentials.password
                return .just(guidOrNil)
            }

        passwordPublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.passwordPublisher
                }
                return walletRepo.map(\.credentials.password)
                    .map { key in key.isEmpty ? nil : key }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        hasPasswordPublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<Bool, Never> in
                guard isEnabled else {
                    return walletRepository.hasPasswordPublisher
                }
                return walletRepo.map(\.credentials.password)
                    .map { key in !key.isEmpty }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(password: String) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(password: password)
                }
                return walletRepo.set(keyPath: \.credentials.password, value: password)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(password: String) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepository, walletRepo] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(password: password)
                }
                return walletRepo
                    .set(keyPath: \.credentials.password, value: password)
                    .mapToVoid()
                    .mapError()
            }
            .eraseToAnyPublisher()
    }

    #warning("TODO: NativeWallet should support syncing of password change")
    func sync() -> Completable {
        walletRepository.sync()
    }

    #warning("TODO: NativeWallet should support syncing of password change")
    func syncPublisher() -> AnyPublisher<Void, PasswordRepositoryError> {
        walletRepository.syncPublisher()
    }
}

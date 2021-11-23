// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class SessionTokenRepository: SessionTokenRepositoryAPI {
    let sessionToken: Single<String?>

    let sessionTokenPublisher: AnyPublisher<String?, Never>

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

        sessionToken = nativeWalletEnabled()
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap { isEnabled -> Single<String?> in
                guard isEnabled else {
                    return walletRepository.sessionToken
                }
                let keyOrNil = walletRepo.credentials.sessionToken.isEmpty ? nil : walletRepo.credentials.sessionToken
                return .just(keyOrNil)
            }

        sessionTokenPublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.sessionTokenPublisher
                }
                return walletRepo.map(\.credentials.sessionToken)
                    .map { key in key.isEmpty ? nil : key }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(sessionToken: String) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(sessionToken: sessionToken)
                }
                return walletRepo.set(keyPath: \.credentials.sessionToken, value: sessionToken)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(sessionToken: String) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepo, walletRepository] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(sessionToken: sessionToken)
                }
                return walletRepo.set(keyPath: \.credentials.sessionToken, value: sessionToken)
                    .mapToVoid()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func cleanSessionToken() -> Completable {
        nativeWalletFlagEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.cleanSessionToken()
                }
                return walletRepo.set(keyPath: \.credentials.sessionToken, value: "")
                    .asCompletable()
            }
            .asCompletable()
    }

    func cleanSessionTokenPublisher() -> AnyPublisher<Void, Never> {
        nativeWalletFlagEnabled()
            .flatMap { [walletRepository, walletRepo] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.cleanSessionTokenPublisher()
                }
                return walletRepo.set(keyPath: \.credentials.sessionToken, value: "")
                    .mapToVoid()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

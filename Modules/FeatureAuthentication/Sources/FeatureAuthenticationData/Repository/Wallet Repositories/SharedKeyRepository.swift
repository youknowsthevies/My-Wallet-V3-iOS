// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class SharedKeyRepository: SharedKeyRepositoryAPI {

    let sharedKey: Single<String?>
    let sharedKeyPublisher: AnyPublisher<String?, Never>

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

        sharedKey = nativeWalletEnabled()
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap { isEnabled -> Single<String?> in
                guard isEnabled else {
                    return walletRepository.sharedKey
                }
                let keyOrNil = walletRepo.credentials.sharedKey.isEmpty ? nil : walletRepo.credentials.sharedKey
                return .just(keyOrNil)
            }

        sharedKeyPublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.sharedKeyPublisher
                }
                return walletRepo.map(\.credentials.sharedKey)
                    .map { key in key.isEmpty ? nil : key }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(sharedKey: String) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(sharedKey: sharedKey)
                }
                return walletRepo.set(keyPath: \.credentials.sharedKey, value: sharedKey)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepo, walletRepository] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(sharedKey: sharedKey)
                }
                return walletRepo.set(keyPath: \.credentials.sharedKey, value: sharedKey)
                    .mapToVoid()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class SyncPubKeysRepository: SyncPubKeysRepositoryAPI {
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
    }

    func set(syncPubKeys: Bool) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(syncPubKeys: syncPubKeys)
                }
                return walletRepo
                    .set(keyPath: \.properties.syncPubKeys, value: syncPubKeys)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(syncPubKeys: Bool) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepository, walletRepo] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(syncPubKeys: syncPubKeys)
                }
                return walletRepo
                    .set(keyPath: \.properties.syncPubKeys, value: syncPubKeys)
                    .mapToVoid()
            }
            .eraseToAnyPublisher()
    }
}

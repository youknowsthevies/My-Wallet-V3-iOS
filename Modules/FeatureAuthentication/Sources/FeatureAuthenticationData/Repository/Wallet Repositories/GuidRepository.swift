// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class GuidRepository: GuidRepositoryAPI {
    let guid: Single<String?>
    let guidPublisher: AnyPublisher<String?, Never>

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

        guid = nativeWalletEnabled()
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap { isEnabled -> Single<String?> in
                guard isEnabled else {
                    return walletRepository.guid
                }
                let guidOrNil = walletRepo.credentials.guid.isEmpty ? nil : walletRepo.credentials.guid
                return .just(guidOrNil)
            }

        guidPublisher = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.guidPublisher
                }
                return walletRepo.map(\.credentials.guid)
                    .map { key in key.isEmpty ? nil : key }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(guid: String) -> Completable {
        nativeWalletEnabled()
            .asObservable()
            .flatMap { [walletRepository, walletRepo] isEnabled -> Completable in
                guard isEnabled else {
                    return walletRepository.set(guid: guid)
                }
                return walletRepo.set(keyPath: \.credentials.guid, value: guid)
                    .asCompletable()
            }
            .asCompletable()
    }

    func setPublisher(guid: String) -> AnyPublisher<Void, Never> {
        nativeWalletEnabled()
            .flatMap { [walletRepo, walletRepository] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletRepository.setPublisher(guid: guid)
                }
                return walletRepo.set(keyPath: \.credentials.guid, value: guid)
                    .mapToVoid()
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

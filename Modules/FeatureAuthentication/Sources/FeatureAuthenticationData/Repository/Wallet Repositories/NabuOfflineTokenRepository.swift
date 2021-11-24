// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift
import WalletPayloadKit

final class NabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI {

    let offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError>

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

        offlineToken = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                guard isEnabled else {
                    return walletRepository.offlineToken
                }
                guard let userId = walletRepo.userId,
                      let offlineToken = walletRepo.lifetimeToken
                else {
                    return .failure(.offlineToken)
                }
                return .just(
                    NabuOfflineToken(
                        userId: userId,
                        token: offlineToken,
                        created: nil
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        nativeWalletEnabled()
            .flatMap { [walletRepository, walletRepo] isEnabled -> AnyPublisher<Void, CredentialWritingError> in
                guard isEnabled else {
                    return walletRepository.set(offlineToken: offlineToken)
                }
                return walletRepo
                    .set(keyPath: \.lifetimeToken, value: offlineToken.token)
                    .set(keyPath: \.userId, value: offlineToken.userId)
                    .mapToVoid()
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}

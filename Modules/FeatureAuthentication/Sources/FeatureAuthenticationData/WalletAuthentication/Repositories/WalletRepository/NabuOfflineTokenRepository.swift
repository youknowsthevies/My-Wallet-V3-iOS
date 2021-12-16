// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class NabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI {

    let offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError>

    // This is set to the older WalletRepository API, soon to be removed
    private let walletRepository: WalletRepositoryAPI
    private let credentialsFetcher: UserCredentialsFetcherAPI
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    init(
        walletRepository: WalletRepositoryAPI,
        credentialsFetcher: UserCredentialsFetcherAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletRepository = walletRepository
        self.credentialsFetcher = credentialsFetcher
        self.nativeWalletEnabled = nativeWalletEnabled

        offlineToken = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<NabuOfflineToken, MissingCredentialsError> in
                guard isEnabled else {
                    return walletRepository.offlineToken
                }
                return credentialsFetcher.fetchUserCredentials()
                    .map { credentials in
                        NabuOfflineToken(
                            userId: credentials.userId,
                            token: credentials.lifetimeToken
                        )
                    }
                    .mapError { _ in MissingCredentialsError.offlineToken }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError> {
        nativeWalletEnabled()
            .flatMap { [walletRepository, credentialsFetcher] isEnabled -> AnyPublisher<Void, CredentialWritingError> in
                guard isEnabled else {
                    return walletRepository.set(offlineToken: offlineToken)
                }
                return credentialsFetcher.store(
                    credentials: UserCredentials(
                        userId: offlineToken.userId,
                        lifetimeToken: offlineToken.token
                    )
                )
                .mapError { _ in CredentialWritingError.offlineToken }
                .mapToVoid()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

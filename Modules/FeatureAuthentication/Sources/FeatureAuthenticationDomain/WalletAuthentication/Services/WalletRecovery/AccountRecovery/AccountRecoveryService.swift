// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit

final class AccountRecoveryService: AccountRecoveryServiceAPI {

    // MARK: - Properties

    private let jwtService: JWTServiceAPI
    private let accountRecoveryRepository: AccountRecoveryRepositoryAPI
    private let credentialsRepository: NabuOfflineTokenRepositoryAPI

    // MARK: - Setup

    init(
        jwtService: JWTServiceAPI = resolve(),
        accountRecoveryRepository: AccountRecoveryRepositoryAPI = resolve(),
        credentialsRepository: NabuOfflineTokenRepositoryAPI = resolve()
    ) {
        self.jwtService = jwtService
        self.accountRecoveryRepository = accountRecoveryRepository
        self.credentialsRepository = credentialsRepository
    }

    // MARK: - API

    func resetVerificationStatus(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, AccountRecoveryServiceError> {
        jwtService
            .fetchToken(guid: guid, sharedKey: sharedKey)
            .mapError(AccountRecoveryServiceError.jwtService)
            .flatMap { [accountRecoveryRepository] jwtToken
                -> AnyPublisher<(NabuOfflineToken, jwtToken: String), AccountRecoveryServiceError> in
                accountRecoveryRepository
                    .createOrGetNabuUser(jwtToken: jwtToken)
            }
            .flatMap { [accountRecoveryRepository] offlineToken, jwtToken
                -> AnyPublisher<Void, AccountRecoveryServiceError> in
                if let created = offlineToken.created, !created {
                    return accountRecoveryRepository
                        .resetUser(offlineToken: offlineToken, jwtToken: jwtToken)
                }
                return .just(())
            }
            .eraseToAnyPublisher()
    }

    func recoverUser(
        guid: String,
        sharedKey: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineToken, AccountRecoveryServiceError> {
        jwtService
            .fetchToken(guid: guid, sharedKey: sharedKey)
            .mapError(AccountRecoveryServiceError.jwtService)
            .flatMap { [accountRecoveryRepository] jwtToken
                -> AnyPublisher<NabuOfflineToken, AccountRecoveryServiceError> in
                accountRecoveryRepository
                    .recoverUser(
                        jwtToken: jwtToken,
                        userId: userId,
                        recoveryToken: recoveryToken
                    )
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func store(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Void, AccountRecoveryServiceError> {
        credentialsRepository
            .set(offlineToken: offlineToken)
            .mapError(AccountRecoveryServiceError.failedToSaveOfflineToken)
            .eraseToAnyPublisher()
    }
}

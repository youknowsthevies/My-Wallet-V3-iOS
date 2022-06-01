// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureAuthenticationDomain

final class AccountRecoveryRepository: AccountRecoveryRepositoryAPI {

    // MARK: - Properties

    private let userCreationClient: NabuUserCreationClientAPI
    private let userResetClient: NabuResetUserClientAPI
    private let userRecoveryClient: NabuUserRecoveryClientAPI

    // MARK: - Setup

    init(
        userCreationClient: NabuUserCreationClientAPI = resolve(),
        userResetClient: NabuResetUserClientAPI = resolve(),
        userRecoveryClient: NabuUserRecoveryClientAPI = resolve()
    ) {
        self.userCreationClient = userCreationClient
        self.userResetClient = userResetClient
        self.userRecoveryClient = userRecoveryClient
    }

    // MARK: - API

    func createOrGetNabuUser(
        jwtToken: String
    ) -> AnyPublisher<(NabuOfflineToken, jwtToken: String), AccountRecoveryServiceError> {
        userCreationClient
            .createUser(for: jwtToken)
            .map(NabuOfflineToken.init)
            .map { ($0, jwtToken) }
            .mapError(AccountRecoveryServiceError.network)
            .eraseToAnyPublisher()
    }

    func resetUser(
        offlineToken: NabuOfflineToken,
        jwtToken: String
    ) -> AnyPublisher<Void, AccountRecoveryServiceError> {
        let response = NabuOfflineTokenResponse(from: offlineToken)
        return userResetClient
            .resetUser(offlineToken: response, jwt: jwtToken)
            .mapError(AccountRecoveryServiceError.network)
            .eraseToAnyPublisher()
    }

    func recoverUser(
        jwtToken: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineToken, AccountRecoveryServiceError> {
        userRecoveryClient
            .recoverUser(
                jwt: jwtToken,
                userId: userId,
                recoveryToken: recoveryToken
            )
            .map(NabuOfflineToken.init)
            .mapError(AccountRecoveryServiceError.network)
            .eraseToAnyPublisher()
    }
}

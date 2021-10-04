// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol AccountRecoveryRepositoryAPI {
    /// Creates or gets nabu user associated with the logged in wallet
    /// - Parameters:
    ///   - jwtToken: The JWT for accessing nabu service (from JWTService)
    /// - Returns: An `AnyPublisher` that sends a tuple with the offline token object and the jwtToken (for other client to use) on success
    func createOrGetNabuUser(
        jwtToken: String
    ) -> AnyPublisher<(NabuOfflineToken, jwtToken: String), AccountRecoveryServiceError>

    /// Resets the nabu user KYC status
    /// - Parameters:
    ///   - offlineToken: nabu offline token object
    ///   - jwtToken: JWT for accessing nabu services
    func resetUser(
        offlineToken: NabuOfflineToken,
        jwtToken: String
    ) -> AnyPublisher<Void, AccountRecoveryServiceError>

    /// Recovers the nabu user (by creating a new wallet and re-link the user)
    /// - Parameters:
    ///   - guid: The wallet GUID
    ///   - sharedKey: The wallet sharedKey
    ///   - userId: nabu user ID, from the email login deeplink
    ///   - recoveryToken: token for recovery, from the email login deeplink
    func recoverUser(
        offlineToken: NabuOfflineToken,
        jwtToken: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineToken, AccountRecoveryServiceError>
}

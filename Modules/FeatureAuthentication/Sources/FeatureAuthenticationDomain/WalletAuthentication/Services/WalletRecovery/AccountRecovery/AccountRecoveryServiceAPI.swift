// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError
import WalletPayloadKit

public enum AccountRecoveryServiceError: Error, Equatable {
    case jwtService(JWTServiceError)
    case network(NetworkError)
    case failedToSaveOfflineToken(CredentialWritingError)
}

public protocol AccountRecoveryServiceAPI {
    /// Reset users' KYC status. This will downgrade the user tier to Tier 0, and restrict custodial funds access. Expected to be used when users completed mnemonic recovery.
    /// - Parameters:
    ///   - guid: The wallet GUID
    ///   - sharedKey: The wallet sharedKey
    func resetVerificationStatus(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, AccountRecoveryServiceError>

    /// Recover users' custodial account. This will create a new wallet and assigns the old custodial account to the new wallet. Expected to be used when users completed reset account
    /// - Parameters:
    ///   - guid: The wallet GUID
    ///   - sharedKey: The wallet sharedKey
    ///   - userId: nabu user ID, from the email login deeplink
    ///   - recoveryToken: token for recovery, from the email login deeplink
    func recoverUser(
        guid: String,
        sharedKey: String,
        userId: String,
        recoveryToken: String
    ) -> AnyPublisher<NabuOfflineToken, AccountRecoveryServiceError>

    /// Stores a `NabuOfflineToken` to wallet metadata
    /// - Parameter offlineToken: A `NabuOfflineToken` object
    /// - Returns: `AnyPublisher<Void, AccountRecoveryServiceError>`
    func store(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<Void, AccountRecoveryServiceError>
}

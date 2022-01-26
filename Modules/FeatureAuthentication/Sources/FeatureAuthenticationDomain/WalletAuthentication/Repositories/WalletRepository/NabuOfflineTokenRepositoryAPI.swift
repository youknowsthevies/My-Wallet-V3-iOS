// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public protocol NabuOfflineTokenRepositoryAPI: AnyObject {
    /// The lifetime token object (userId, token) for the nabu account. It will be used for generating session token for accessing various nabu related services
    var offlineToken: AnyPublisher<NabuOfflineToken, MissingCredentialsError> { get }

    /// Sets the nabu lifetime token in the wallet repository
    /// - Parameters:
    ///   - offlinToken: lifetime token object
    /// - Returns: An `AnyPublisher` that returns Void on sucesss or `CredentialsWritingError` if failed
    func set(offlineToken: NabuOfflineToken) -> AnyPublisher<Void, CredentialWritingError>
}

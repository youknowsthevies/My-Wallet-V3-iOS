// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol NabuRepositoryAPI {

    /// Get or create a nabu user. This will call the get or create endpoint in the nabu service.
    /// - Parameters:
    ///   - jwtToken: A JWT token for authentication
    /// - Returns:
    ///   - An `AnyPublisher` that returns the Nabu user lifetime token or network error on failure
    func createUser(for jwtToken: String) -> AnyPublisher<NabuOfflineToken, NetworkError>

    /// Obtain a session token for accessing nabu services.
    /// - Parameters:
    ///  - guid: wallet GUID
    ///  - userToken: nabu lifetime (offline) token
    ///  - userIdentifier: nabu userID
    ///  - deviceId: mobile deviceID
    ///  - email: wallet email
    /// - Returns:
    ///  - An `AnyPublisher` that returns the Nabu session token or network error on failure
    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionToken, NetworkError>
}

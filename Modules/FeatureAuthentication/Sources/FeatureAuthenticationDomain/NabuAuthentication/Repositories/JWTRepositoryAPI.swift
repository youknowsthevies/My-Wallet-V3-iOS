// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol JWTRepositoryAPI {
    /// Request a JWT (JSON web token) for accessing the nabu related services. JWT is usually required for the nabu related endpoints.
    /// - Parameters:
    ///   - guid: The wallet GUID
    ///   - sharedKey: The wallet sharedKey
    /// - Returns: A `Combine.Publisher` that publishes a JWT String or `JWTServiceError` if failed
    func requestJWT(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, JWTServiceError>
}

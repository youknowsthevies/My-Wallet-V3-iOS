// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol NabuTokenRepositoryAPI {

    /// The nabu session token object
    var sessionTokenPublisher: AnyPublisher<NabuSessionToken?, Never> { get }

    /// The session token string
    var sessionToken: String? { get }

    /// If session token is nil, refresh it
    var requiresRefresh: AnyPublisher<Bool, Never> { get }

    /// Invalidate the session token cache
    func invalidate() -> AnyPublisher<Void, Never>

    /// Cache the nabu session token in an in-memory cache (Atomic)
    /// - Parameters:
    ///  - sessionToken: Nabu session token object obtained from repository
    /// - Returns:
    ///  - An `AnyPublisher` that returns a nabu session token object and never fails
    func store(_ sessionToken: NabuSessionToken) -> AnyPublisher<NabuSessionToken, Never>
}

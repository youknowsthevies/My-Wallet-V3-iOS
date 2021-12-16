// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol RemoteGuidRepositoryAPI {

    /// Fetches a guid by a session token
    func guid(token: String) -> AnyPublisher<String?, GuidServiceError>
}

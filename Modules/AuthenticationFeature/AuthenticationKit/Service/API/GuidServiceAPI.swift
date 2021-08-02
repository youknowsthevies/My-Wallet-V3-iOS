// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import RxSwift

// MARK: - Types

public enum GuidServiceError: Error {
    case missingSessionToken
    case networkError(NetworkError)
}

public protocol GuidServiceCombineAPI: AnyObject {
    /// An `AnyPublisher` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guidPublisher: AnyPublisher<String, GuidServiceError> { get }
}

/// A `GUID` client/service API. A concrete type is expected to fetch the `GUID`
public protocol GuidServiceAPI: GuidServiceCombineAPI {
    /// A `Single` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guid: Single<String> { get }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public protocol GuidClientCombineAPI: AnyObject {
    /// An `AnyPublisher` that streams the `GUID` on success or fails due
    /// to network error.
    func guidPublisher(by sessionToken: String) -> AnyPublisher<String, GuidServiceError>
}

/// A `GUID` client/service API. A concrete type is expected to fetch the `GUID`
public protocol GuidClientAPI: GuidClientCombineAPI {
    /// A `Single` that streams the `GUID` on success or fails due
    /// to network error.
    func guid(by sessionToken: String) -> Single<String>
}

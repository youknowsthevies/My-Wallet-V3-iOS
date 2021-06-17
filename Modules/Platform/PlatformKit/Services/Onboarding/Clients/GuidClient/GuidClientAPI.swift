// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// A `GUID` client/service API. A concrete type is expected to fetch the `GUID`
public protocol GuidClientAPI: AnyObject {
    /// A `Single` that streams the `GUID` on success or fails due
    /// to network error.
    func guid(by sessionToken: String) -> Single<String>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// A `GUID` client/service API. A concrete type is expected to fetch the `GUID`
public protocol GuidServiceAPI: class {
    /// A `Single` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guid: Single<String> { get }
}

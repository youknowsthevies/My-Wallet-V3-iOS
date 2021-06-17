// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SessionTokenClientAPI: AnyObject {
    /// A Single that streams the session token
    var token: Single<String> { get }
}

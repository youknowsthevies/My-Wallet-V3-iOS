// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import RxSwift

public protocol SessionTokenClientCombineAPI: AnyObject {
    /// A Single that streams the session token
    var tokenPublisher: AnyPublisher<String?, NetworkError> { get }
}

public protocol SessionTokenClientAPI: SessionTokenClientCombineAPI {
    /// A Single that streams the session token
    var token: Single<String> { get }
}

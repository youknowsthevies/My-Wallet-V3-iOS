// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public protocol SessionTokenClientCombineAPI: AnyObject {
    /// A Single that streams the session token
    var tokenPublisher: AnyPublisher<String, SessionTokenServiceError> { get }
}

public protocol SessionTokenClientAPI: SessionTokenClientCombineAPI {
    /// A Single that streams the session token
    var token: Single<String> { get }
}

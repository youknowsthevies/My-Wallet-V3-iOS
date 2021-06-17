// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AuthenticatorRepositoryAPI: AnyObject {

    /// Streams the authenticator type
    var authenticatorType: Single<AuthenticatorType> { get }

    /// Sets the authenticator type
    func set(authenticatorType: AuthenticatorType) -> Completable
}

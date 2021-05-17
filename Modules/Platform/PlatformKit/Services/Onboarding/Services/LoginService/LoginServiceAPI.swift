// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Service that provides login methods
public protocol LoginServiceAPI: class {

    /// Standard login using cached `GUID` and `session-token`
    func login(walletIdentifier: String) -> Completable

    /// 2FA login using using cached `GUID` and `session-token`,
    /// and an OTP (from an authenticator app)
    func login(walletIdentifier: String, code: String) -> Completable
}

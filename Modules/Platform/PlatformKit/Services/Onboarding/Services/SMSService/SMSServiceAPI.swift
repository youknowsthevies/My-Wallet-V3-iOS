// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SMSServiceAPI: class {
    /// Requests SMS OTP
    func request() -> Completable
}

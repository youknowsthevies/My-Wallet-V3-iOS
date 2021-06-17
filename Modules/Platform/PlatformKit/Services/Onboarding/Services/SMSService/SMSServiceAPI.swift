// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol SMSServiceAPI: AnyObject {
    /// Requests SMS OTP
    func request() -> Completable
}

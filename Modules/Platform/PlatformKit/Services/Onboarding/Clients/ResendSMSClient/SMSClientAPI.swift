// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Client API for SMS
public protocol SMSClientAPI: AnyObject {

    /// Requests the server to send a new OTP
    func requestOTP(sessionToken: String, guid: String) -> Completable
}

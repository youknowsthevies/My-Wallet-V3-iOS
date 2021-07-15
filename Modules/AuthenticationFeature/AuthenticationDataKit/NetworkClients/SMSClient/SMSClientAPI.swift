// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public protocol SMSClientCombineAPI: AnyObject {

    /// Requests the server to send a new OTP
    func requestOTPPublisher(sessionToken: String, guid: String) -> AnyPublisher<Void, SMSServiceError>
}

/// Client API for SMS
public protocol SMSClientAPI: SMSClientCombineAPI {

    /// Requests the server to send a new OTP
    func requestOTP(sessionToken: String, guid: String) -> Completable
}

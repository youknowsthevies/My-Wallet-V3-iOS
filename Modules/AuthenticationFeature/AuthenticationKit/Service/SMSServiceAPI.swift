// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import RxSwift

/// A potential SMS service error
public enum SMSServiceError: LocalizedError {

    /// missing credentials
    case missingCredentials(MissingCredentialsError)

    /// other network errors
    case networkError(NetworkError)
}

public protocol SMSServiceCombineAPI: AnyObject {
    /// Requests SMS OTP
    func requestPublisher() -> AnyPublisher<Void, SMSServiceError>
}

public protocol SMSServiceAPI: SMSServiceCombineAPI {
    /// Requests SMS OTP
    func request() -> Completable
}

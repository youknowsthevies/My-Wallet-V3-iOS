// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol SMSRepositoryAPI {

    /// Request a SMS verification code from the backend
    func request(
        sessionToken: String,
        guid: String
    ) -> AnyPublisher<Void, SMSServiceError>
}

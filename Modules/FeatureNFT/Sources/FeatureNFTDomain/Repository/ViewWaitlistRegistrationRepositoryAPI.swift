// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public enum ViewWalletRegistrationServiceError: Error {
    case emailUnavailable
    case network(NabuNetworkError)
}

public protocol ViewWaitlistRegistrationRepositoryAPI {
    func registerEmailForNFTViewWaitlist() -> AnyPublisher<Void, ViewWalletRegistrationServiceError>
}

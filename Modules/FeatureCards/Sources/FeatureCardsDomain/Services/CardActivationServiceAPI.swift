// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError
import ToolKit

public enum CardActivationServiceError: Swift.Error, TimeoutFailure {
    case nabu(NabuNetworkError)
    case timeout
}

public protocol CardActivationServiceAPI: AnyObject {

    /// Poll for activation
    func waitForActivation(
        of cardId: String
    ) -> AnyPublisher<Result<CardActivationState, CardActivationServiceError>, Never>
}

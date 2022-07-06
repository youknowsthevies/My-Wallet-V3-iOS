// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import PlatformKit

public protocol AvailablePairsRepositoryAPI {

    var availableOrderPairs: AnyPublisher<[OrderPair], NabuNetworkError> { get }
}

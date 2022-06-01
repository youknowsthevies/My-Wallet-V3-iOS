// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol AvailablePairsClientAPI {

    var availableOrderPairs: AnyPublisher<AvailableTradingPairsResponse, NabuNetworkError> { get }
}

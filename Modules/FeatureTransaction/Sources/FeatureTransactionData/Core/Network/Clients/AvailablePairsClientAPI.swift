// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol AvailablePairsClientAPI {

    var availableOrderPairs: AnyPublisher<AvailableTradingPairsResponse, NabuNetworkError> { get }
}

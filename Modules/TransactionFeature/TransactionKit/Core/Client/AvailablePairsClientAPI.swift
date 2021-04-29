// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol AvailablePairsClientAPI {
    var availableOrderPairs: Single<AvailableTradingPairsResponse> { get }
}

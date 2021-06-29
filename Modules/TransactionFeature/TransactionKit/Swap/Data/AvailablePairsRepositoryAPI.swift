// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AvailablePairsRepositoryAPI {

    var availableOrderPairs: Single<[OrderPair]> { get }
}

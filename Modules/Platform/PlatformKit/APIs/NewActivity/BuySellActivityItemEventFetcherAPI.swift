// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol BuySellActivityItemEventFetcherAPI {
    var buySellActivity: Single<[BuySellActivityItemEvent]> { get }
}

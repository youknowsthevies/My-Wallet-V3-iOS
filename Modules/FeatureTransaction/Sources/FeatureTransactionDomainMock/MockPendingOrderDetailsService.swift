// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit

public final class MockPendingOrderDetailsService: PendingOrderDetailsServiceAPI {

    public struct StubbedResults {
        public var pendingOrderDetails: Single<OrderDetails?> = .just(nil)
        public var pendingActionOrderDetails: Single<OrderDetails?> = .just(nil)
        public var cancel: Completable = .empty()
    }

    public var stubbedResults = StubbedResults()

    public var pendingOrderDetails: Single<OrderDetails?> {
        stubbedResults.pendingOrderDetails
    }

    public var pendingActionOrderDetails: Single<OrderDetails?> {
        stubbedResults.pendingActionOrderDetails
    }

    public func cancel() -> Completable {
        stubbedResults.cancel
    }
}

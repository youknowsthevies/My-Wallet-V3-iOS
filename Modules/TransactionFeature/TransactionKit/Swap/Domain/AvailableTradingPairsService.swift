// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol AvailableTradingPairsServiceAPI {

    /// Streams cached `[OrderPair]`, or fetch from
    /// remote if they are not cached
    var availableTradingPairs: Single<[OrderPair]> { get }

    /// Fetches `[OrderPair]` from remote
    func fetchTradingPairs() -> Single<[OrderPair]>
}

final class AvailableTradingPairsService: AvailableTradingPairsServiceAPI {

    // MARK: - AvailableTradingPairsServiceAPI

    var availableTradingPairs: Single<[OrderPair]> {
        _ = setup
        return pairsCachedValue.valueSingle
    }

    // MARK: - CachedValue

    private lazy var setup: Void = {
        pairsCachedValue.setFetch(weak: self) { (self) in
            self.client
                .availableOrderPairs
                .map(\.pairs)
                .map { $0.compactMap { OrderPair(rawValue: $0) } }
        }
    }()

    // MARK: - Properties

    private let pairsCachedValue = CachedValue<[OrderPair]>(
        configuration: .init(
            refreshType: .onSubscription,
            flushNotificationName: .logout
        )
    )

    private let client: AvailablePairsClientAPI

    // MARK: - Setup

    init(client: AvailablePairsClientAPI = resolve()) {
        self.client = client
    }

    func fetchTradingPairs() -> Single<[OrderPair]> {
        _ = setup
        return pairsCachedValue.fetchValue
    }
}

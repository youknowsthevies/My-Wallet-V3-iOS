// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Errors
import RxRelay
import RxSwift
import RxToolKit
import ToolKit

public enum OrdersServiceError: Error {
    case mappingError
    case network(NabuNetworkError)
}

public protocol OrdersServiceAPI: AnyObject {

    var hasUserMadeAnyPurchases: AnyPublisher<Bool, OrdersServiceError> { get }

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: Single<[OrderDetails]> { get }

    /// Fetches the orders from remote
    func fetchOrders() -> Single<[OrderDetails]>

    /// Fetches the order for a given identifier
    func fetchOrder(with identifier: String) -> Single<OrderDetails>
}

final class OrdersService: OrdersServiceAPI {

    // MARK: - Service Error

    private struct CacheKey: Hashable {}

    // MARK: - Exposed

    var hasUserMadeAnyPurchases: AnyPublisher<Bool, OrdersServiceError> {
        cachedAccumulatedTrades
            .stream(key: CacheKey())
            .compactMap { result -> [AccumulatedTradeDetails]? in
                guard case .success(let values) = result else {
                    return nil
                }
                return values
            }
            .map { accumulatedTradeAmounts -> Bool in
                guard let tradedAmountOfAllTime = accumulatedTradeAmounts.first(where: { $0.period == .all }) else {
                    return false
                }
                return !tradedAmountOfAllTime.amount.isZero
            }
            .setFailureType(to: OrdersServiceError.self)
            .eraseToAnyPublisher()
    }

    var orders: Single<[OrderDetails]> {
        ordersCachedValue.valueSingle
    }

    private let ordersCachedValue = CachedValue<[OrderDetails]>(
        configuration: .periodic(
            seconds: 60,
            schedulerIdentifier: "OrdersService"
        )
    )

    private let cachedAccumulatedTrades: CachedValueNew<
        CacheKey,
        [AccumulatedTradeDetails],
        OrdersServiceError
    >

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: OrderDetailsClientAPI

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        client: OrderDetailsClientAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        ordersCachedValue.setFetch { [client, analyticsRecorder] in
            client.orderDetails(pendingOnly: false)
                .asSingle()
                .map { orders in
                    orders.compactMap {
                        OrderDetails(recorder: analyticsRecorder, response: $0)
                    }
                }
        }

        let accumulatedTrades: AnyCache<CacheKey, [AccumulatedTradeDetails]> = InMemoryCache(
            configuration: .onLoginLogoutTransactionAndDashboardRefresh(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        cachedAccumulatedTrades = CachedValueNew(
            cache: accumulatedTrades,
            fetch: { _ in
                client
                    .fetchAccumulatedTradeAmounts()
                    .mapError(OrdersServiceError.network)
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchOrders() -> Single<[OrderDetails]> {
        ordersCachedValue.fetchValue
    }

    func fetchOrder(with identifier: String) -> Single<OrderDetails> {
        client.orderDetails(with: identifier)
            .map { [analyticsRecorder] response in
                OrderDetails(recorder: analyticsRecorder, response: response)
            }
            .asSingle()
            .onNil(error: OrdersServiceError.mappingError)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxRelay
import RxSwift
import ToolKit

public protocol OrdersServiceAPI: class {

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
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Exposed
    
    var orders: Single<[OrderDetails]> {
        _ = setup
        return ordersCachedValue.valueSingle
    }
    
    private let ordersCachedValue = CachedValue<[OrderDetails]>(
        configuration: .init(
            refreshType: .onSubscription,
            flushNotificationName: .logout
        )
    )

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: OrderDetailsClientAPI
    
    private lazy var setup: Void = {
        ordersCachedValue.setFetch(weak: self) { (self) in
            self.client.orderDetails(pendingOnly: false)
                .map(weak: self) { (self, rawOrders) in
                    rawOrders.compactMap {
                        OrderDetails(recorder: self.analyticsRecorder, response: $0)
                    }
                }
        }
    }()
    
    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording = resolve(),
         client: OrderDetailsClientAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
    }
    
    func fetchOrders() -> Single<[OrderDetails]> {
        _ = setup
        return ordersCachedValue.fetchValue
    }
    
    func fetchOrder(with identifier: String) -> Single<OrderDetails> {
        _ = setup
        return client.orderDetails(with: identifier)
            .map(weak: self) { (self, response) in
                OrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> OrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
    }
}

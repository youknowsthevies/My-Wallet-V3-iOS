// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol OrderDetailsClientAPI: AnyObject {

    /// Fetch all Buy/Sell orders
    func orderDetails(
        pendingOnly: Bool
    ) -> AnyPublisher<[OrderPayload.Response], NabuNetworkError>

    /// Fetch a single Buy/Sell order
    func orderDetails(
        with identifier: String
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError>
}

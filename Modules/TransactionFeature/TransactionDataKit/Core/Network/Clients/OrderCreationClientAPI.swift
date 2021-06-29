// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import TransactionKit

protocol OrderCreationClientAPI {

    func create(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError>
}

protocol OrderUpdateClientAPI {

    func updateOrder(
        with transactionId: String,
        success: Bool
    ) -> AnyPublisher<Void, NabuNetworkError>
}

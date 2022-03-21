// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError
import PlatformKit

public protocol OrderFetchingRepositoryAPI {

    func fetchTransaction(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError>
}

extension OrderFetchingRepositoryAPI {

    public func fetchTransactionStatus(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent.EventStatus, NabuNetworkError> {
        fetchTransaction(with: transactionId)
            .map(\.status)
            .eraseToAnyPublisher()
    }
}

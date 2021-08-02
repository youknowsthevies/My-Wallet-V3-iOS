// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import TransactionKit

final class OrderUpdateRepository: OrderUpdateRepositoryAPI {

    // MARK: - Properties

    private let client: OrderUpdateClientAPI

    // MARK: - Setup

    init(client: OrderUpdateClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderCreationServiceAPI

    func updateOrder(
        identifier: String,
        success: Bool
    ) -> AnyPublisher<Void, NabuNetworkError> {
        client
            .updateOrder(
                with: identifier,
                success: success
            )
    }
}

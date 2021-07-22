// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
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
    ) -> Completable {
        client
            .updateOrder(
                with: identifier,
                success: success
            )
            .asObservable()
            .ignoreElements()
    }
}

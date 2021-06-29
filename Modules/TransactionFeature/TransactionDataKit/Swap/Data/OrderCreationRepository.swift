// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import PlatformKit
import TransactionKit

final class OrderCreationRepository: OrderCreationRepositoryAPI {

    // MARK: - Properties

    private let client: OrderCreationClientAPI

    // MARK: - Setup

    init(client: OrderCreationClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderCreationServiceAPI

    func createOrder(direction: OrderDirection,
                     quoteIdentifier: String,
                     volume: MoneyValue,
                     destinationAddress: String?,
                     refundAddress: String?) -> Single<SwapOrder> {
        client
            .create(
                direction: direction,
                quoteIdentifier: quoteIdentifier,
                volume: volume,
                destinationAddress: destinationAddress,
                refundAddress: refundAddress
            )
            .map(SwapOrder.init)
            .asObservable()
            .asSingle()
    }
}

extension SwapOrder {

    fileprivate init(response: SwapActivityItemEvent) {
        self.init(
            identifier: response.identifier,
            state: response.status,
            depositAddress: response.kind.depositAddress
        )
    }
}

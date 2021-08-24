// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import TransactionKit

final class TransactionLimitsRepository: TransactionLimitsRepositoryAPI {

    // MARK: - Properties

    private let client: OrderTransactionLimitsClientAPI

    // MARK: - Setup

    init(client: OrderTransactionLimitsClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - TransactionLimitServiceAPI

    func fetchTransactionLimits(
        currency: CurrencyType,
        networkFee: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TransactionLimits, NabuNetworkError> {
        client
            .fetchTransactionLimits(
                currency: currency,
                networkFee: networkFee,
                product: product
            )
            .map(TransactionLimits.init)
            .eraseToAnyPublisher()
    }
}

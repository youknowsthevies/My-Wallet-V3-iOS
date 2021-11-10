// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import NabuNetworkError
import PlatformKit

final class TransactionLimitsRepository: TransactionLimitsRepositoryAPI {

    // MARK: - Properties

    private let client: OrderTransactionLimitsClientAPI

    // MARK: - Setup

    init(client: OrderTransactionLimitsClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - TransactionLimitServiceAPI

    func fetchTradeLimits(
        sourceCurrency: CurrencyType,
        destinationCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<FeatureTransactionDomain.TradeLimits, NabuNetworkError> {
        client
            .fetchTransactionLimits(
                currency: sourceCurrency,
                networkFee: destinationCurrency,
                product: product
            )
            .map(TradeLimits.init)
            .eraseToAnyPublisher()
    }

    func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: CurrencyType
    ) -> AnyPublisher<FeatureTransactionDomain.CrossBorderLimits, NabuNetworkError> {
        // TODO: implement me
        .empty()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

final class TransactionLimitsRepository: TransactionLimitsRepositoryAPI {

    // MARK: - Properties

    private let client: TransactionLimitsClientAPI

    // MARK: - Setup

    init(client: TransactionLimitsClientAPI) {
        self.client = client
    }

    // MARK: - TransactionLimitServiceAPI

    func fetchTradeLimits(
        sourceCurrency: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TradeLimits, NabuNetworkError> {
        client
            .fetchTradeLimits(
                currency: sourceCurrency,
                product: product
            )
            .map(TradeLimits.init)
            .eraseToAnyPublisher()
    }

    func fetchCrossBorderLimits(
        source: LimitsAccount,
        destination: LimitsAccount,
        limitsCurrency: FiatCurrency
    ) -> AnyPublisher<CrossBorderLimits, NabuNetworkError> {
        client
            .fetchCrossBorderLimits(
                source: source,
                destination: destination,
                limitsCurrency: limitsCurrency.currencyType
            )
            .map(CrossBorderLimits.init)
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import NabuNetworkError
import PlatformKit

protocol OrderTransactionLimitsClientAPI {

    func fetchTransactionLimits(
        currency: CurrencyType,
        networkFee: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TransactionLimitsResponse, NabuNetworkError>
}

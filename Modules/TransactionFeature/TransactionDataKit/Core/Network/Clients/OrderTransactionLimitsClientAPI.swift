// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import TransactionKit

protocol OrderTransactionLimitsClientAPI {

    func fetchTransactionLimits(
        currency: CurrencyType,
        networkFee: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TransactionLimitsResponse, NabuNetworkError>
}

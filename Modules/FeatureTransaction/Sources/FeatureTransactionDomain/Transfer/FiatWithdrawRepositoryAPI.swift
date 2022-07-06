// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol FiatWithdrawRepositoryAPI {

    func createWithdrawOrder(
        id: String,
        amount: MoneyValue
    ) -> AnyPublisher<Void, NabuNetworkError>
}

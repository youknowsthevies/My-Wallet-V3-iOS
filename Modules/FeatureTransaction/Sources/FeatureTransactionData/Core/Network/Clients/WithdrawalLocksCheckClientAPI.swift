// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol WithdrawalLocksCheckClientAPI {
    func fetchWithdrawalLocksCheck(
        paymentMethod: String,
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocksCheckResponse, NabuNetworkError>
}

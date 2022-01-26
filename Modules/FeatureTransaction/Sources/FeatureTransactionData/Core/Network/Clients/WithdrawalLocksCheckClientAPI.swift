// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol WithdrawalLocksCheckClientAPI {
    func fetchWithdrawalLocksCheck(
        paymentMethod: String,
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocksCheckResponse, NabuNetworkError>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol WithdrawalLocksCheckRepositoryAPI {

    func withdrawalLocksCheck(
        paymentMethod: String?,
        currencyCode: String?
    ) -> AnyPublisher<WithdrawalLocksCheck, Never>
}

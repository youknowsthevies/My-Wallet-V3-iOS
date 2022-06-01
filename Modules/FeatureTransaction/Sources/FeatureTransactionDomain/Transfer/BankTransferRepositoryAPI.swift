// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol BankTransferRepositoryAPI {

    func startBankTransfer(
        id: String,
        amount: MoneyValue
    ) -> AnyPublisher<BankTranferPayment, NabuNetworkError>
}

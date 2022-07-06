// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

protocol CustodialPaymentAccountClientAPI {

    func custodialPaymentAccount(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<PaymentAccount.Response, NabuNetworkError>
}

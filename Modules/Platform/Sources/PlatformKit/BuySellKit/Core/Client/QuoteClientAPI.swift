// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol QuoteClientAPI: AnyObject {

    func getQuote(
        for action: Order.Action,
        to cryptoCurrency: CryptoCurrency,
        amount: FiatValue
    ) -> AnyPublisher<QuoteResponse, NabuNetworkError>
}

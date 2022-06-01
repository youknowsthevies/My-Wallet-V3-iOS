// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import PlatformKit

protocol OrderFetchingClientAPI {

    func fetchTransaction(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError>
}

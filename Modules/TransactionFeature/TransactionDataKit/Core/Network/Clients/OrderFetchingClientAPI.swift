// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import Combine

protocol OrderFetchingClientAPI {
    
    func fetchTransaction(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError>
}

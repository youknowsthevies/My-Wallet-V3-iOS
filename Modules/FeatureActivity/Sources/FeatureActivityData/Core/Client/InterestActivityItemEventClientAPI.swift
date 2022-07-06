// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

protocol InterestActivityItemEventClientAPI {
    func fetchInterestActivityItemEventsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<InterestActivityResponse, NabuNetworkError>
}

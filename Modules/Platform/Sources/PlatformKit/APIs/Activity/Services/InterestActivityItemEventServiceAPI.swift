// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol InterestActivityItemEventServiceAPI: AnyObject {
    func fetchInterestActivityItemEventsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[InterestActivityItemEvent], InterestActivityServiceError>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol InterestAccountRateClientAPI: AnyObject {

    func fetchAllInterestAccountRates()
        -> AnyPublisher<SupportedInterestAccountRatesResponse, NabuNetworkError>

    func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NabuNetworkError>
}

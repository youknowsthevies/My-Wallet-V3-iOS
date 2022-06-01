// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

protocol InterestAccountLimitsClientAPI: AnyObject {
    func fetchInterestAccountLimitsResponseForFiatCurrency(_ fiatCurrency: FiatCurrency)
        -> AnyPublisher<InterestAccountLimitsResponse, NabuNetworkError>
}

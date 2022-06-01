// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

protocol InterestAccountReceiveAddressClientAPI {
    func fetchInterestAccountReceiveAddressResponse(
        _ currencyCode: String
    ) -> AnyPublisher<InterestReceiveAddressResponse, NabuNetworkError>
}

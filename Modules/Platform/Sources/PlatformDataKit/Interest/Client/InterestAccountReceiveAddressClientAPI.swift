// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol InterestAccountReceiveAddressClientAPI {
    func fetchInterestAccountReceiveAddressResponse(
        _ currencyCode: String
    ) -> AnyPublisher<InterestReceiveAddressResponse, NabuNetworkError>
}

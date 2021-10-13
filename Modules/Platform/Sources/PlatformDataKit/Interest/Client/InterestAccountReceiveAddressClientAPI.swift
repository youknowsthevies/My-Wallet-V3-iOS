// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

protocol InterestAccountReceiveAddressClientAPI {
    func fetchInterestAccountReceiveAddressResponse()
        -> AnyPublisher<InterestReceiveAddressResponse, NabuNetworkError>
}

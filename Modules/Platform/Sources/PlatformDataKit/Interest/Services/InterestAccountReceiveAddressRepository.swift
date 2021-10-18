// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit

final class InterestAccountReceiveAddressRepository: InterestAccountReceiveAddressRepositoryAPI {

    private let client: InterestAccountReceiveAddressClientAPI

    init(
        client: InterestAccountReceiveAddressClientAPI = resolve()
    ) {
        self.client = client
    }

    func fetchInterestAccountReceiveAddressForCurrencyCode(
        _ code: String
    ) -> AnyPublisher<String, InterestAccountReceiveAddressError> {
        client
            .fetchInterestAccountReceiveAddressResponse(code)
            .mapError(InterestAccountReceiveAddressError.networkError)
            .map(\.accountRef)
            .eraseToAnyPublisher()
    }
}

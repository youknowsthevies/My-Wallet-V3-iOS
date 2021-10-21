// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol InterestAccountReceiveAddressRepositoryAPI {

    /// Fetches the interest account receive address for a given
    /// currency code.
    /// - Parameter code: A currency code
    func fetchInterestAccountReceiveAddressForCurrencyCode(
        _ code: String
    ) -> AnyPublisher<String, InterestAccountReceiveAddressError>
}

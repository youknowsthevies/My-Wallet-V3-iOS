// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol ApplePayRepositoryAPI {

    func applePayInfo(
        for currency: String
    ) -> AnyPublisher<ApplePayInfo, NabuNetworkError>
}

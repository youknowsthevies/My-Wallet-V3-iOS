// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol RatesRepositoryAPI {

    func fetchRate(
        code: String
    ) -> AnyPublisher<Double, NetworkError>
}

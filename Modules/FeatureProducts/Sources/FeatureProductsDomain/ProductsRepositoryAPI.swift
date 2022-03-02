// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

public protocol ProductsRepositoryAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
    func streamProducts() -> AnyPublisher<Result<[Product], NabuNetworkError>, Never>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

public protocol ProductsRepositoryAPI {

    func fetchProducts() -> AnyPublisher<[ProductValue], NabuNetworkError>
    func streamProducts() -> AnyPublisher<Result<[ProductValue], NabuNetworkError>, Never>
}

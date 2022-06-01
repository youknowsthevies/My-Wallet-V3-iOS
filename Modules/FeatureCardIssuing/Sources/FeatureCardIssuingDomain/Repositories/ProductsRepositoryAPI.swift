// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol ProductsRepositoryAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
}

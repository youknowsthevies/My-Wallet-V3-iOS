// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

public protocol ProductsRepositoryAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

public protocol ProductsServiceAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
}

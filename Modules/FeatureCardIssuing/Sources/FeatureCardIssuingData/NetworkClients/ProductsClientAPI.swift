// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

protocol ProductsClientAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
}

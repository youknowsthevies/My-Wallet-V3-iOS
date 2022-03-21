// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError

protocol ProductsClientAPI {

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError>
}

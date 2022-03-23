// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError

final class ProductsRepository: ProductsRepositoryAPI {

    private let client: ProductsClientAPI

    init(client: ProductsClientAPI) {
        self.client = client
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        client.fetchProducts()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import NabuNetworkError
import NetworkKit

public protocol ProductsClientAPI {

    func fetchProductsData() -> AnyPublisher<ProductsAPIResponse, NabuNetworkError>
}

public final class ProductsAPIClient: ProductsClientAPI {

    private enum Path {
        static let products: [String] = ["products"]
    }

    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(networkAdapter: NetworkAdapterAPI, requestBuilder: RequestBuilder) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchProductsData() -> AnyPublisher<ProductsAPIResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.products,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

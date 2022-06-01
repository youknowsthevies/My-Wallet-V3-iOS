// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class ProductsClient: ProductsClientAPI {

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: ProductsClientRequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = ProductsClientRequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {

        let request = requestBuilder.build()
        return networkAdapter
            .perform(request: request, responseType: [Product].self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request Builder

extension ProductsClient {

    private struct ProductsClientRequestBuilder {

        // MARK: - Types

        private let pathComponents = ["products"]

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        // MARK: - Setup

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build() -> NetworkRequest {
            requestBuilder.get(
                path: pathComponents,
                authenticated: true
            )!
        }
    }
}

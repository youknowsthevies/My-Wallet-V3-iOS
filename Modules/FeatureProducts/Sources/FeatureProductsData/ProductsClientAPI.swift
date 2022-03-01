// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
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
        // NOTE: The API implementetion doesn't respect spec. Will be rediscussed on Feb 28 2022
//        let request = requestBuilder.get(
//            path: Path.products,
//            authenticated: true
//        )!
//        return networkAdapter.perform(request: request)

        let stubbedResponse = ProductsAPIResponse(
            products: [
                ProductAPIResponse(
                    id: "BUY",
                    maxOrdersCap: 1,
                    canPlaceOrder: true,
                    suggestedUpgrade: nil
                ),
                ProductAPIResponse(
                    id: "SWAP",
                    maxOrdersCap: 1,
                    canPlaceOrder: true,
                    suggestedUpgrade: nil
                )
            ]
        )
        return .just(stubbedResponse)
    }
}

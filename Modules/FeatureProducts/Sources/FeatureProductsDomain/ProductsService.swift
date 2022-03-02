// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError
import ToolKit

public enum ProductsServiceError: Error, Equatable {
    case network(NabuNetworkError)
}

public protocol ProductsServiceAPI {

    func fetchProducts() -> AnyPublisher<[Product], ProductsServiceError>
    func streamProducts() -> AnyPublisher<Result<[Product], ProductsServiceError>, Never>
}

public final class ProductsService: ProductsServiceAPI {

    private let repository: ProductsRepositoryAPI

    public init(repository: ProductsRepositoryAPI) {
        self.repository = repository
    }

    public func fetchProducts() -> AnyPublisher<[Product], ProductsServiceError> {
        repository.fetchProducts()
            .mapError(ProductsServiceError.network)
            .eraseToAnyPublisher()
    }

    public func streamProducts() -> AnyPublisher<Result<[Product], ProductsServiceError>, Never> {
        repository.streamProducts()
            .map { result in
                result.mapError(ProductsServiceError.network)
            }
            .eraseToAnyPublisher()
    }
}

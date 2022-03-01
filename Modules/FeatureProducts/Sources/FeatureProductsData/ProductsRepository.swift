// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureProductsDomain
import NabuNetworkError
import ToolKit

public final class ProductsRepository: ProductsRepositoryAPI {

    private enum CacheKey: Hashable {
        case products
    }

    private let cachedProducts: CachedValueNew<CacheKey, [Product], NabuNetworkError>

    public init(client: ProductsClientAPI) {
        let cache: AnyCache<CacheKey, [Product]> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        cachedProducts = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchProductsData()
                    .map([Product].init)
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        cachedProducts.get(key: CacheKey.products)
    }

    public func streamProducts() -> AnyPublisher<Result<[Product], NabuNetworkError>, Never> {
        cachedProducts.stream(key: CacheKey.products)
    }
}

// MARK: - Parsing Helpers

extension Array where Element == Product {

    fileprivate init(_ response: ProductsAPIResponse) {
        self = response.products.compactMap(Product.init)
    }
}

extension Product {

    fileprivate init?(_ response: ProductAPIResponse) {
        guard let identifier = Product.Identifier(rawValue: response.id) else {
            return nil
        }
        self.init(
            id: identifier,
            maxOrdersCap: response.maxOrdersCap,
            canPlaceOrder: response.canPlaceOrder,
            suggestedUpgrade: response.suggestedUpgrade.map(Product.SuggestedUpgrade.init)
        )
    }
}

extension Product.SuggestedUpgrade {

    fileprivate init(_ response: ProductAPIResponse.SuggestedUpgrade) {
        self.init(requiredTier: response.requiredTier)
    }
}

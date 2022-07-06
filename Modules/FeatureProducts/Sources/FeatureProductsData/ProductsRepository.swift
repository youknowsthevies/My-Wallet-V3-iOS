// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProductsDomain
import ToolKit

public final class ProductsRepository: ProductsRepositoryAPI {

    private enum CacheKey: Hashable {
        case products
    }

    private let cachedProducts: CachedValueNew<CacheKey, [ProductValue], NabuNetworkError>

    public init(client: ProductsClientAPI) {
        let cache: AnyCache<CacheKey, [ProductValue]> = InMemoryCache(
            configuration: .onUserStateChanged(),
            refreshControl: PerpetualCacheRefreshControl()
        )
        .eraseToAnyCache()

        cachedProducts = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchProductsData()
                    .map([ProductValue].init)
                    .eraseToAnyPublisher()
            }
        )
    }

    public func fetchProducts() -> AnyPublisher<[ProductValue], NabuNetworkError> {
        cachedProducts.get(key: CacheKey.products)
    }

    public func streamProducts() -> AnyPublisher<Result<[ProductValue], NabuNetworkError>, Never> {
        cachedProducts.stream(key: CacheKey.products)
    }
}

// MARK: - Parsing Helpers

extension Array where Element == ProductValue {

    /// This may not be the best interface for this but works for now. To be revisited.
    fileprivate init(_ response: ProductsAPIResponse) {
        self = [
            ProductValue.trading(response.buy),
            ProductValue.trading(response.swap),
            ProductValue.custodialWallet(response.custodialWallets)
        ]
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import ToolKit

enum LatestBlockRepositoryError: Error {
    case failed(Error)
}

protocol LatestBlockRepositoryAPI {
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<BigInt, LatestBlockRepositoryError>
}

final class LatestBlockRepository: LatestBlockRepositoryAPI {

    private let client: LatestBlockClientAPI
    private let cachedValue: CachedValueNew<
        EVMNetwork,
        BigInt,
        LatestBlockRepositoryError
    >

    init(client: LatestBlockClientAPI = resolve()) {
        self.client = client

        let cache: AnyCache<EVMNetwork, BigInt> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 10)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] network in
                client
                    .latestBlock(network: network)
                    .mapError(LatestBlockRepositoryError.failed)
                    .map(\.result)
                    .eraseToAnyPublisher()
            }
        )
    }

    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<BigInt, LatestBlockRepositoryError> {
        cachedValue.get(key: network)
    }
}

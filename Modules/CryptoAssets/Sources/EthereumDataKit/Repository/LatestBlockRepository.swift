// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import EthereumKit
import NetworkError
import ToolKit

final class LatestBlockRepository: LatestBlockRepositoryAPI {

    private let client: LatestBlockClientAPI
    private let cachedValue: CachedValueNew<
        EVMNetwork,
        BigInt,
        NetworkError
    >

    init(client: LatestBlockClientAPI) {
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
                    .map(\.result)
                    .eraseToAnyPublisher()
            }
        )
    }

    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<BigInt, NetworkError> {
        cachedValue.get(key: network)
    }
}

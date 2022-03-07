// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit
import ToolKit

public enum EthereumNonceRepositoryError: Error {
    case failed(Error)
}

public protocol EthereumNonceRepositoryAPI {
    func invalidateCache()
    func nonce(for address: String) -> AnyPublisher<BigUInt, EthereumNonceRepositoryError>
}

final class EthereumNonceRepository: EthereumNonceRepositoryAPI {

    private let client: GetTransactionCountClientAPI
    private let cachedValue: CachedValueNew<
        String,
        BigUInt,
        EthereumNonceRepositoryError
    >

    init(
        client: GetTransactionCountClientAPI = resolve()
    ) {
        self.client = client

        let cache: AnyCache<String, BigUInt> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] address in
                client
                    .transactionCount(address: address)
                    .map(\.result.magnitude)
                    .mapError(EthereumNonceRepositoryError.failed)
                    .eraseToAnyPublisher()
            }
        )
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func nonce(for address: String) -> AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        cachedValue.get(key: address)
    }
}

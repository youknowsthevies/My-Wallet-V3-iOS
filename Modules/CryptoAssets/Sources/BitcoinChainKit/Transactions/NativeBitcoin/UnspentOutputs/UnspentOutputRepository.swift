// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkError
import PlatformKit
import ToolKit

protocol UnspentOutputRepositoryAPI {

    /// Emits unspent outputs of the provided addresses (extended public key)
    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputs, NetworkError>
}

final class UnspentOutputRepository: UnspentOutputRepositoryAPI {

    // MARK: - Private properties

    private let client: APIClientAPI
    private let cachedValue: CachedValueNew<
        Set<XPub>, UnspentOutputs, NetworkError
    >

    // MARK: - Init

    init(
        client: APIClientAPI = resolve()
    ) {
        self.client = client
        let cache: AnyCache<Set<XPub>, UnspentOutputs> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] xPubs in
                client
                    .unspentOutputs(for: Array(xPubs))
                    .map(UnspentOutputs.init(networkResponse:))
                    .eraseToAnyPublisher()
            }
        )
    }

    // MARK: - Methods

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputs, NetworkError> {
        cachedValue.get(key: Set(addresses))
    }
}

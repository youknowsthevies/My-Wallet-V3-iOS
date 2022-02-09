// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public enum EthereumBalanceRepositoryError: Error {
    case failed(Error)
}

public protocol EthereumBalanceRepositoryAPI {
    func invalidateCache()
    func balance(
        for address: String
    ) -> AnyPublisher<CryptoValue, EthereumBalanceRepositoryError>
}

final class EthereumBalanceRepository: EthereumBalanceRepositoryAPI {

    private let client: GetBalanceClientAPI
    private let cachedValue: CachedValueNew<
        String,
        CryptoValue,
        EthereumBalanceRepositoryError
    >

    init(
        client: GetBalanceClientAPI = resolve()
    ) {
        self.client = client

        let cache: AnyCache<String, CryptoValue> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 30)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] address in
                client
                    .balance(address: address)
                    .map { response -> CryptoValue in
                        CryptoValue.create(minor: response.result, currency: .coin(.ethereum))
                    }
                    .mapError(EthereumBalanceRepositoryError.failed)
                    .eraseToAnyPublisher()
            }
        )
    }

    func invalidateCache() {
        cachedValue.invalidateCache()
    }

    func balance(
        for address: String
    ) -> AnyPublisher<CryptoValue, EthereumBalanceRepositoryError> {
        cachedValue.get(key: address)
    }
}

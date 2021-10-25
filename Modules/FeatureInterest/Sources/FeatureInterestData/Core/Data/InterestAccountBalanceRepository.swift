// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureInterestDomain
import PlatformKit
import RxSwift
import ToolKit

final class InterestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI {

    private let client: InterestAccountBalanceClientAPI
    private let cachedValue: CachedValueNew<
        FiatCurrency,
        InterestAccountBalances,
        InterestAccountBalanceRepositoryError
    >

    init(client: InterestAccountBalanceClientAPI = resolve()) {
        self.client = client
        let cache: AnyCache<FiatCurrency, InterestAccountBalances> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 90)
        )
        .eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key in
                client.fetchBalanceWithFiatCurrency(key)
                    .replaceNil(with: .empty)
                    .replaceError(with: .empty)
                    .mapError(InterestAccountBalanceRepositoryError.networkError)
                    .map(InterestAccountBalances.init)
                    .eraseToAnyPublisher()
            }
        )
    }

    func fetchInterestAccountsBalance(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountBalances, InterestAccountBalanceRepositoryError> {
        cachedValue.get(key: fiatCurrency)
    }
}

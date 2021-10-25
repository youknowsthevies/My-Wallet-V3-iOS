// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol TradingBalanceServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }

    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState>
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
}

class TradingBalanceService: TradingBalanceServiceAPI {

    private struct Key: Hashable {}

    // MARK: - Properties

    var balances: Single<CustodialAccountBalanceStates> {
        cachedValue.get(key: Key())
            .asSingle()
            .catchErrorJustReturn(.absent)
    }

    // MARK: - Private Properties

    private let client: TradingBalanceClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        CustodialAccountBalanceStates,
        Error
    >

    // MARK: - Setup

    init(client: TradingBalanceClientAPI = resolve()) {
        self.client = client

        let cache: AnyCache<Key, CustodialAccountBalanceStates> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] _ in
                client
                    .balance
                    .map { response in
                        guard let response = response else {
                            return .absent
                        }
                        return CustodialAccountBalanceStates(response: response)
                    }
                    .eraseError()
            }
        )
    }

    // MARK: - Methods

    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState> {
        balances
            .map { response -> CustodialAccountBalanceState in
                response[currencyType]
            }
    }

    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        cachedValue
            .get(key: Key(), forceFetch: true)
            .asSingle()
            .catchErrorJustReturn(.absent)
    }
}

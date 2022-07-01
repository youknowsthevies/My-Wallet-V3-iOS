// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import ToolKit

final class TransactionRepository: TransactionRepositoryAPI {

    private let cachedValue: CachedValueNew<
        String,
        [Card.Transaction],
        NabuNetworkError
    >
    private let cache: AnyCache<String, [Card.Transaction]>
    private let client: TransactionClientAPI

    init(client: TransactionClientAPI) {
        self.client = client

        cache = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ in
                client.fetchTransactions()
            }
        )
    }

    func fetchTransactions() -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        cachedValue.get(key: #file)
    }

    func fetchMore() -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        cachedValue
            .get(key: #file)
            .flatMap { [weak self] transactions -> AnyPublisher<[Card.Transaction], NabuNetworkError> in
                guard let self = self else {
                    return .empty()
                }

                guard let transaction = transactions.last else {
                    return self.client.fetchTransactions()
                }

                return self.client
                    .fetchTransactions(
                        TransactionsParams(
                            cardId: nil,
                            types: nil,
                            from: nil,
                            to: nil,
                            toId: transaction.id,
                            fromId: nil,
                            limit: nil
                        )
                    )
                    .flatMap { requestedTransactions -> AnyPublisher<[Card.Transaction], NabuNetworkError> in
                        let mergedTransactions = transactions + requestedTransactions
                        return self.cache
                            .set(mergedTransactions, for: #file)
                            .map { _ in mergedTransactions }
                            .setFailureType(to: NabuNetworkError.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

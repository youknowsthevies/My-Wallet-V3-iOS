// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import NetworkKit

protocol TransactionClientAPI {

    /// Get a transaction detail with given hash.
    func transaction(
        with hash: String
    ) -> AnyPublisher<EthereumHistoricalTransactionResponse, NetworkError>

    /// Get a transactions for account.
    func transactions(
        for account: String
    ) -> AnyPublisher<[EthereumHistoricalTransactionResponse], NetworkError>
}

final class TransactionClient: TransactionClientAPI {

    // MARK: - Types

    /// Privately used endpoint data
    private enum Endpoint {

        static func transactions(for address: String) -> String {
            "/v2/eth/data/account/\(address)/transactions"
        }

        static func transaction(with hash: String) -> String {
            "/v2/eth/data/transaction/\(hash)"
        }
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func transaction(
        with hash: String
    ) -> AnyPublisher<EthereumHistoricalTransactionResponse, NetworkError> {
        let path = Endpoint.transaction(with: hash)
        let request = requestBuilder.get(path: path)!
        return networkAdapter.perform(request: request)
    }

    /// Fetches transactions for an address - returns an array of transactions
    func transactions(
        for account: String
    ) -> AnyPublisher<[EthereumHistoricalTransactionResponse], NetworkError> {
        let path = Endpoint.transactions(for: account)
        let request = requestBuilder.get(path: path)!
        return networkAdapter
            .perform(
                request: request,
                responseType: EthereumAccountTransactionsResponse.self
            )
            .map(\.transactions)
            .eraseToAnyPublisher()
    }
}

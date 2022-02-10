// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import NetworkKit
import PlatformKit

protocol TransactionPushClientAPI: AnyObject {

    /// Push transaction.
    func push(
        transaction: EthereumTransactionEncoded
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError>
}

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

protocol TransactionFeeClientAPI {

    func fees(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError>
}

final class APIClient: TransactionPushClientAPI,
    TransactionClientAPI,
    TransactionFeeClientAPI
{

    // MARK: - Types

    /// Privately used endpoint data
    private enum Endpoint {
        static let fees: [String] = ["mempool", "fees", "eth"]
        static let pushTx: [String] = ["eth", "pushtx"]
    }

    /// Privately used endpoint data
    private enum EndpointV2 {
        private static let base: [String] = ["v2", "eth", "data"]

        static func transactions(for address: String) -> [String] {
            base + ["account", address, "transactions"]
        }

        static func transaction(with hash: String) -> [String] {
            base + ["transaction", hash]
        }
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(),
        apiCode: APICode = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    func fees(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError> {
        guard cryptoCurrency == .coin(.ethereum) || cryptoCurrency.isERC20 else {
            fatalError("Using Ethereum APIClient for incompatible CryptoCurrency")
        }
        var parameters: [URLQueryItem] = []
        if let contractAddress = cryptoCurrency.erc20ContractAddress {
            parameters.append(URLQueryItem(name: "contractAddress", value: contractAddress))
        }
        let request = requestBuilder.get(
            path: Endpoint.fees,
            parameters: parameters
        )!
        return networkAdapter.perform(request: request)
    }

    /// Pushes a transaction
    func push(
        transaction: EthereumTransactionEncoded
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError> {
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTransaction,
            api_code: apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        let request = requestBuilder.post(
            path: Endpoint.pushTx,
            body: data,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func transaction(
        with hash: String
    ) -> AnyPublisher<EthereumHistoricalTransactionResponse, NetworkError> {
        let path = EndpointV2.transaction(with: hash)
        let request = requestBuilder.get(path: path)!
        return networkAdapter.perform(request: request)
    }

    /// Fetches transactions for an address - returns an array of transactions
    func transactions(
        for account: String
    ) -> AnyPublisher<[EthereumHistoricalTransactionResponse], NetworkError> {
        let path = EndpointV2.transactions(for: account)
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

extension CryptoCurrency {
    var erc20ContractAddress: String? {
        switch self {
        case .erc20(let model):
            switch model.kind {
            case .erc20(let contractAddress):
                return contractAddress
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

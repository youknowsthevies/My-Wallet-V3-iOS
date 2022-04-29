// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import NetworkKit
import PlatformKit

protocol TransactionPushClientAPI: AnyObject {

    /// Push transaction.
    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetwork
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError>
}

protocol TransactionFeeClientAPI {

    func fees(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError>
}

final class APIClient: TransactionPushClientAPI, TransactionFeeClientAPI {

    // MARK: - Types

    /// Privately used endpoint data
    private enum Endpoint {

        static func fees(network: EVMNetwork) -> String {
            switch network {
            case .ethereum:
                return "/mempool/fees/eth"
            case .polygon:
                return "/mempool/fees/matic"
            }
        }

        static func pushTx(network: EVMNetwork) -> String {
            switch network {
            case .ethereum:
                return "/eth/pushtx"
            case .polygon:
                return "/currency/evm/pushTx"
            }
        }

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
        fees(
            contractAddress: cryptoCurrency.assetModel.kind.erc20ContractAddress,
            network: network(from: cryptoCurrency)
        )
    }

    private func network(from cryptoCurrency: CryptoCurrency) -> EVMNetwork {
        guard let network = cryptoCurrency.assetModel.evmNetwork else {
            let code = cryptoCurrency.code
            let chain = cryptoCurrency.assetModel.kind.erc20ParentChain?.rawValue ?? ""
            fatalError("Incompatible Asset: '\(code)', chain: '\(chain)'.")
        }
        return network
    }

    private func fees(
        contractAddress: String?,
        network: EVMNetwork
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError> {
        var parameters: [URLQueryItem] = []
        if let contractAddress = contractAddress {
            parameters.append(URLQueryItem(name: "contractAddress", value: contractAddress))
        }
        let request = requestBuilder.get(
            path: Endpoint.fees(network: network),
            parameters: parameters
        )!
        return networkAdapter.perform(request: request)
    }

    /// Pushes a transaction
    func push(
        transaction: EthereumTransactionEncoded,
        network: EVMNetwork
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError> {
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTransaction,
            network: network.rawValue,
            api_code: apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        let request = requestBuilder.post(
            path: Endpoint.pushTx(network: network),
            body: data,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }
}

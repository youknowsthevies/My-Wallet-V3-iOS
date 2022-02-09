// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Foundation
import NetworkKit
import PlatformKit

protocol LatestBlockClientAPI {
    /// Streams the latest block number.
    var latestBlock: AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> { get }
}

protocol EstimateGasClientAPI {
    /// Estimate gas (gas limit) of the given ethereum transaction.
    func estimateGas(
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetCodeClientAPI {
    /// Get contract code (if any) on the given address.
    func code(
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError>
}

protocol GetTransactionCountClientAPI {
    /// Get the transaction count (nonce) of a given ethereum address.
    func transactionCount(
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetBalanceClientAPI {
    /// Get the ethereum balance of a given ethereum address.
    func balance(
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

final class RPCClient: LatestBlockClientAPI,
    EstimateGasClientAPI,
    GetBalanceClientAPI,
    GetTransactionCountClientAPI,
    GetCodeClientAPI
{

    private enum Endpoint {
        static let rpcNode: [String] = ["eth", "nodes", "rpc"]
    }

    // MARK: - Properties

    var latestBlock: AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            encodable: BlockNumberRequest()
        )
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

    func balance(
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            encodable: GetBalanceRequest(address: address)
        )
    }

    func transactionCount(
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            encodable: GetTransactionCountRequest(address: address)
        )
    }

    func estimateGas(
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            encodable: EstimateGasRequest(transaction: transaction)
        )
    }

    func code(
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        createAndPerformHexaDataRPCRequest(
            encodable: GetCodeRequest(address: address)
        )
    }

    private func createAndPerformHexaDataRPCRequest(
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        rpcRequest(encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func createAndPerformHexaNumberRPCRequest(
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        rpcRequest(encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func rpcRequest(encodable: Encodable) -> Result<NetworkRequest, NetworkError> {
        guard let data = try? encodable.data() else {
            return .failure(.payloadError(.emptyData))
        }
        return requestBuilder.post(
            path: Endpoint.rpcNode,
            body: data
        )
        .flatMap { .success($0) }
        ?? .failure(.payloadError(.emptyData))
    }
}

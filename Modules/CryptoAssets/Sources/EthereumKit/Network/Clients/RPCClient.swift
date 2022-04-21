// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Foundation
import NetworkKit
import PlatformKit

protocol LatestBlockClientAPI {
    /// Streams the latest block number.
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol EstimateGasClientAPI {
    /// Estimate gas (gas limit) of the given ethereum transaction.
    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetCodeClientAPI {
    /// Get contract code (if any) on the given address.
    func code(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError>
}

protocol GetTransactionCountClientAPI {
    /// Get the transaction count (nonce) of a given ethereum address.
    func transactionCount(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

protocol GetBalanceClientAPI {
    /// Get the ethereum balance of a given ethereum address.
    func balance(
        network: EVMNetwork,
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
        private static let ethereumNode: [String] = ["eth", "nodes", "rpc"]
        private static let polygonNode: [String] = ["matic-bor", "nodes", "rpc"]

        static func nodePath(for network: EVMNetwork) -> [String] {
            switch network {
            case .ethereum:
                return ethereumNode
            case .polygon:
                return polygonNode
            }
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

    // MARK: - RPCClient

    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: BlockNumberRequest()
        )
    }

    func balance(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: GetBalanceRequest(address: address)
        )
    }

    func transactionCount(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: GetTransactionCountRequest(address: address)
        )
    }

    func estimateGas(
        network: EVMNetwork,
        transaction: EthereumJsonRpcTransaction
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        createAndPerformHexaNumberRPCRequest(
            network: network,
            encodable: EstimateGasRequest(transaction: transaction)
        )
    }

    func code(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        createAndPerformHexaDataRPCRequest(
            network: network,
            encodable: GetCodeRequest(address: address)
        )
    }

    private func createAndPerformHexaDataRPCRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaDataResponse, NetworkError> {
        rpcRequest(network: network, encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func createAndPerformHexaNumberRPCRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError> {
        rpcRequest(network: network, encodable: encodable)
            .publisher
            .flatMap { [networkAdapter] networkRequest in
                networkAdapter.perform(request: networkRequest)
            }
            .eraseToAnyPublisher()
    }

    private func rpcRequest(
        network: EVMNetwork,
        encodable: Encodable
    ) -> Result<NetworkRequest, NetworkError> {
        guard let data = try? encodable.data() else {
            return .failure(.payloadError(.emptyData))
        }
        return requestBuilder.post(
            path: Endpoint.nodePath(for: network),
            body: data
        )
        .flatMap { .success($0) }
        ?? .failure(.payloadError(.emptyData))
    }
}

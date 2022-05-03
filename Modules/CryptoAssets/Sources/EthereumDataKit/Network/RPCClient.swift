// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import NetworkError
import NetworkKit

protocol LatestBlockClientAPI {
    /// Streams the latest block number.
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<JsonRpcHexaNumberResponse, NetworkError>
}

final class RPCClient: LatestBlockClientAPI {

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
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder,
        apiCode: APICode
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

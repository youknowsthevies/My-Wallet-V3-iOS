// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import Foundation
import NetworkKit

protocol ERC20ActivityClientAPI {

    func ethereumERC20Activity(
        from address: String,
        contractAddress: String
    ) -> AnyPublisher<ERC20TransfersResponse, NetworkError>
}

final class ERC20ActivityClient: ERC20ActivityClientAPI {

    // MARK: - Private Types

    private enum Endpoint {
        static func transactions(for address: String, contractAddress: String) -> String {
            "/v2/eth/data/account/\(address)/token/\(contractAddress)/transfers"
        }
    }

    // MARK: - Private Properties

    private let apiCode: APICode
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        apiCode: APICode,
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.apiCode = apiCode
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func ethereumERC20Activity(
        from address: String,
        contractAddress: String
    ) -> AnyPublisher<ERC20TransfersResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Endpoint.transactions(for: address, contractAddress: contractAddress)
        )!
        return networkAdapter.perform(request: request)
    }
}

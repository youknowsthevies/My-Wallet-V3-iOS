// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

final class ERC20AccountAPIClient: ERC20AccountAPIClientAPI {

    // MARK: - Private Types

    private enum EndpointV2 {
        private static func base() -> [String] { ["eth"] }
        private static func account(for address: String) -> [String] {
            base() + ["account", address]
        }

        private static var account: [String] {
            ["v2", "eth", "data", "account"]
        }

        static func transactions(for address: String, contractAddress: String) -> [String] {
            account + [address, "token", contractAddress, "transfers"]
        }
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI

    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func fetchTransactions(
        from address: String,
        page: String?,
        contractAddress: String
    ) -> AnyPublisher<ERC20TransfersResponse, NetworkError> {
        var parameters: [URLQueryItem] = []
        if let page = page, !page.isEmpty {
            parameters.append(URLQueryItem(name: "page", value: page))
        }
        let path = EndpointV2.transactions(for: address, contractAddress: contractAddress)
        let request = requestBuilder.get(path: path, parameters: parameters)!
        return networkAdapter.perform(request: request)
    }
}

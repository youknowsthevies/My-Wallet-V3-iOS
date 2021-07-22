// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

final class ERC20AccountAPIClient: ERC20AccountAPIClientAPI {

    private enum EndpointV2 {
        private static func base() -> [String] { [ "eth" ] }
        private static func account(for address: String) -> [String] {
            base() + [ "account", address ]
        }
        private static var account: [String] {
            [ "v2", "eth", "data", "account"]
        }

        static func summary(for address: String, contractAddress: String) -> [String] {
            account + [ address, "token", contractAddress, "summary" ]
        }

        static func transactions(for address: String, contractAddress: String) -> [String] {
            account + [ address, "token", contractAddress, "transfers" ]
        }

        static func isContract(with address: String) -> [String] {
            account(for: address) + [ "isContract" ]
        }
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    init(networkAdapter: NetworkAdapterAPI = resolve(),
         requestBuilder: RequestBuilder = resolve()) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func fetchTransactions(from address: String, page: String?, contractAddress: String) -> Single<ERC20TransfersResponse> {
        var parameters: [URLQueryItem] = []
        if let page = page, !page.isEmpty {
            parameters.append(URLQueryItem(name: "page", value: page))
        }
        let path = EndpointV2.transactions(for: address, contractAddress: contractAddress)
        let request = requestBuilder.get(path: path, parameters: parameters)!
        return networkAdapter.perform(request: request)
    }

    func isContract(address: String) -> Single<ERC20IsContractResponse> {
        let path = EndpointV2.isContract(with: address)
        let request = requestBuilder.get(path: path)!
        return networkAdapter.perform(request: request)
    }

    func fetchAccountSummary(from address: String, contractAddress: String) -> Single<ERC20AccountSummaryResponse> {
        let path = EndpointV2.summary(for: address, contractAddress: contractAddress)
        let request = requestBuilder.get(path: path)!
        return networkAdapter.perform(request: request)
    }
}

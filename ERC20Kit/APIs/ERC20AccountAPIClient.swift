//
//  ERC20AccountAPIClientAPI.swift
//  ERC20Kit
//
//  Created by Jack on 16/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

public final class ERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {

    private enum EndpointV2 {
        private static var account: [String] {
            [ "v2", "eth", "data", "account"]
        }

        static func summary(for address: String) -> [String] {
            account + [ address, "token", Token.contractAddress.ethereumAddress.publicKey, "summary" ]
        }

        static func transactions(for address: String) -> [String] {
            account + [ address, "token", Token.contractAddress.ethereumAddress.publicKey, "transfers" ]
        }
    }

    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder

    public init(dependencies: Network.Dependencies = .default) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }

    public func fetchTransactions(from address: String, page: String) -> Single<ERC20TransfersResponse<Token>> {
        let parameters = [ URLQueryItem(name: "page", value: page) ]
        guard let request = requestBuilder.get(path: EndpointV2.transactions(for: address), parameters: parameters) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }

    public func fetchAccountSummary(from address: String) -> Single<ERC20AccountSummaryResponse<Token>> {
        guard let request = requestBuilder.get(path: EndpointV2.summary(for: address)) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }
}

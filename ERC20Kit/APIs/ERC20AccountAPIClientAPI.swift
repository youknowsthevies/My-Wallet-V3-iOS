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

public protocol ERC20AccountAPIClientAPI {
    associatedtype Token: ERC20Token

    func fetchWalletAccount(from address: String, page: String) -> Single<ERC20AccountResponse<Token>>
}

public final class ERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {

    private enum EndpointV2 {
        private static var account: [String] {
            [ "v2", "eth", "data", "account"]
        }

        static func wallet(for address: String) -> [String] {
            account + [ address, "token", Token.contractAddress.rawValue, "wallet" ]
        }
    }

    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder

    public init(dependencies: Network.Dependencies = .default) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }

    public func fetchWalletAccount(from address: String, page: String) -> Single<ERC20AccountResponse<Token>> {
        let parameters = [ URLQueryItem(name: "page", value: page) ]
        guard let request = requestBuilder.get(path: EndpointV2.wallet(for: address), parameters: parameters) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }
}

final class AnyERC20AccountAPIClient<Token: ERC20Token>: ERC20AccountAPIClientAPI {
    private let fetchWalletAccountClosure: (String, String) -> Single<ERC20AccountResponse<Token>>

    init<C: ERC20AccountAPIClientAPI>(accountAPIClient: C) where C.Token == Token {
        fetchWalletAccountClosure = accountAPIClient.fetchWalletAccount
    }

    func fetchWalletAccount(from address: String, page: String) -> Single<ERC20AccountResponse<Token>> {
        return fetchWalletAccountClosure(address, page)
    }
}

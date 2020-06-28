//
//  TradingBalanceClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public protocol TradingBalanceClientAPI: class {
    func balance(for currency: String, token: String) -> Single<CustodialBalanceResponse?>
}

public final class TradingBalanceClient: TradingBalanceClientAPI {

    // MARK: - Types

    private enum Path {
        static let balance = [ "accounts", "simplebuy" ]
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Init

    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }

    // MARK: - TradingBalanceClientAPI

    public func balance(for currency: String, token: String) -> Single<CustodialBalanceResponse?> {
        let path = Path.balance
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            headers: headers
        )!
        return communicator.performOptional(request: request, responseType: CustodialBalanceResponse.self)
    }
}

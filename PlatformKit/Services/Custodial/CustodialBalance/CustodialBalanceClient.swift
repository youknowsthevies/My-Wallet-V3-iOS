//
//  CustodialBalanceClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public protocol CustodialBalanceClientAPI: class {

    /// Fetch all Custodial Balances
    func balance(with authToken: String) -> Single<CustodialBalanceResponse>
}

public final class CustodialBalanceClient: CustodialBalanceClientAPI {

    // MARK: - Types

    enum ClientError: Error {
        case unknown
    }

    private enum Path {
        static let custodialBalance = [ "accounts", "simplebuy" ]
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Init

    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }

    // MARK: - CustodialBalanceClientAPI

    public func balance(with authToken: String) -> Single<CustodialBalanceResponse> {
        let path = Path.custodialBalance
        let headers = [HttpHeaderField.authorization: authToken]
        guard let request = requestBuilder.get(path: path, headers: headers) else {
            return Single.error(ClientError.unknown)
        }
        return communicator.perform(request: request)
    }
}

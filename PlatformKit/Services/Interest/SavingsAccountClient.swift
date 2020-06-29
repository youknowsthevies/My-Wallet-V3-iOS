//
//  SavingsAccountClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol SavingsAccountClientAPI: AnyObject {
    func balance(token: String) -> Single<SavingsAccountBalanceResponse?>
    func rate(for currency: String, token: String) -> Single<SavingsAccountInterestRateResponse>
}

public final class SavingsAccountClient: SavingsAccountClientAPI {
    
    private enum Path {
        static let balance = [ "accounts", "savings" ]
        static let rate = [ "savings", "rates" ]
    }
    
    private enum Parameter {
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup

    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }

    // MARK: - SavingsAccountClientAPI

    public func balance(token: String) -> Single<SavingsAccountBalanceResponse?> {
        let request = requestBuilder.get(
            path: Path.balance,
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.performOptional(request: request, responseType: SavingsAccountBalanceResponse.self)
    }
    
    public func rate(for currency: String, token: String) -> Single<SavingsAccountInterestRateResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.rate,
            parameters: parameters,
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.perform(request: request)
    }
}

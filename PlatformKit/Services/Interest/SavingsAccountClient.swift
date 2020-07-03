//
//  SavingsAccountClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public protocol SavingsAccountClientAPI: AnyObject {
    var balance: Single<SavingsAccountBalanceResponse?> { get }
    func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse>
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
    
    public var balance: Single<SavingsAccountBalanceResponse?> {
        let request = requestBuilder.get(
            path: Path.balance,
            authenticated: true
        )!
        return communicator.performOptional(request: request, responseType: SavingsAccountBalanceResponse.self)
    }
    
    public func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.rate,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
}

//
//  SavingsAccountClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

public protocol SavingsAccountClientAPI: AnyObject {
    var balance: Single<SavingsAccountBalanceResponse?> { get }
    func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse>
}

final class SavingsAccountClient: SavingsAccountClientAPI {
    
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

    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }

    // MARK: - SavingsAccountClientAPI
    
    var balance: Single<SavingsAccountBalanceResponse?> {
        let request = requestBuilder.get(
            path: Path.balance,
            authenticated: true
        )!
        return communicator.performOptional(request: request, responseType: SavingsAccountBalanceResponse.self)
    }
    
    func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse> {
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

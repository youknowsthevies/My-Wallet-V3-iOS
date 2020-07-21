//
//  CustodialClient.swift
//  PlatformKit
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public protocol TradingBalanceClientAPI: class {
    var balance: Single<CustodialBalanceResponse?> { get }
    func balance(for currency: String) -> Single<CustodialBalanceResponse?>
}

public typealias CustodialClientAPI = TradingBalanceClientAPI & CustodyWithdrawalClientAPI

public final class CustodialClient: CustodialClientAPI {
    
    // MARK: - Types
    
    private enum Path {
        static let withdrawal = ["payments", "withdrawals"]
        static let custodialBalance = [ "accounts", "simplebuy" ]
    }
    
    // MARK: - Properties
    
    public var balance: Single<CustodialBalanceResponse?> {
        let path = Path.custodialBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return communicator.performOptional(request: request, responseType: CustodialBalanceResponse.self)
    }
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    // MARK: - TradingBalanceClientAPI

    public func balance(for currency: String) -> Single<CustodialBalanceResponse?> {
        let path = Path.custodialBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return communicator.performOptional(request: request, responseType: CustodialBalanceResponse.self)
    }
    
    // MARK: - CustodyWithdrawalClientAPI
    
    public func withdraw(cryptoValue: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse> {
        let withdrawalRequest = CustodialWithdrawalRequest(address: destination, cryptoValue: cryptoValue)
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? withdrawalRequest.encode(),
            headers: headers,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
}

//
//  CustodialClient.swift
//  PlatformKit
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

public protocol TradingBalanceClientAPI: class {
    var balance: Single<CustodialBalanceResponse?> { get }
    func balance(for currency: String) -> Single<CustodialBalanceResponse?>
}

public typealias CustodialClientAPI = TradingBalanceClientAPI & CustodyWithdrawalClientAPI

final class CustodialClient: CustodialClientAPI {
    
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
    
    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - TradingBalanceClientAPI

    func balance(for currency: String) -> Single<CustodialBalanceResponse?> {
        let path = Path.custodialBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return communicator.performOptional(request: request, responseType: CustodialBalanceResponse.self)
    }
    
    // MARK: - CustodyWithdrawalClientAPI
    
    func withdraw(cryptoValue: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse> {
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

//
//  CustodialClient.swift
//  PlatformKit
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public typealias CustodialClientAPI = TradingBalanceClientAPI &
                                      CustodyWithdrawalClientAPI

public final class CustodialClient: CustodialClientAPI {
    
    // MARK: - Types
    
    enum ClientError: Error {
        case unknown
    }
        
    private enum Path {
        static let withdrawal = ["payments", "withdrawals"]
        static let custodialBalance = [ "accounts", "simplebuy" ]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    // MARK: - TradingBalanceClientAPI

    public func balance(for currency: String, token: String) -> Single<CustodialBalanceResponse> {
        let path = Path.custodialBalance
        let headers = [HttpHeaderField.authorization: token]
        guard let request = requestBuilder.get(path: path, headers: headers) else {
            return Single.error(ClientError.unknown)
        }
        return communicator.perform(request: request)
    }
    
    // MARK: - CustodyWithdrawalClientAPI
    
    public func withdraw(cryptoValue: CryptoValue, destination: String, authToken: String) -> Single<CustodialWithdrawalResponse> {
        let withdrawalRequest = CustodialWithdrawalRequest(address: destination, cryptoValue: cryptoValue)
        let headers = [HttpHeaderField.authorization: authToken,
                       HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? withdrawalRequest.encode(),
            headers: headers
            )!
        return communicator.perform(request: request)
    }
}

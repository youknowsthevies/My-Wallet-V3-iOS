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
import ToolKit

public protocol TradingBalanceClientAPI: class {
    var balance: Single<CustodialBalanceResponse?> { get }
    func balance(for currencyType: CurrencyType) -> Single<CustodialBalanceResponse?>
}

final class CustodialClient: TradingBalanceClientAPI,
                             CustodyWithdrawalClientAPI,
                             CustodialPaymentAccountClientAPI,
                             CustodialPendingDepositClientAPI {
    
    // MARK: - Types
    
    private enum Path {
        static let pendingDeposit = ["payments", "deposits", "pending"]
        static let withdrawal = ["payments", "withdrawals"]
        static let paymentAccount = [ "payments", "accounts", "simplebuy" ]
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
    
    // MARK: - CustodialPendingDepositClientAPI

    func createPendingDeposit(body: CreatePendingDepositRequestBody) -> Completable {
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? body.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - TradingBalanceClientAPI

    func balance(for currencyType: CurrencyType) -> Single<CustodialBalanceResponse?> {
        balance
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
    
    // MARK: - CustodialPaymentAccountClientAPI
    
    func custodialPaymentAccount(for cryptoCurrency: CryptoCurrency) -> Single<PaymentAccount.Response> {
        struct Payload: Encodable {
            let currency: String
        }
        
        let payload = Payload(currency: cryptoCurrency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
}

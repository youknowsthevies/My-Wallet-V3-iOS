//
//  APIClient.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

typealias TransactionKitClientAPI = CustodialQuoteAPI &
                                    OrderCreationClientAPI &
                                    AvailablePairsClientAPI &
                                    OrderTransactionLimitsClientAPI &
                                    OrderFetchingClientAPI &
                                    OrderUpdateClientAPI

/// TransactionKit network client
final class APIClient: TransactionKitClientAPI {
    
    // MARK: - Types
    
    fileprivate enum Parameter {
        static let minor = "minor"
        static let networkFee = "networkFee"
        static let currency = "currency"
    }
        
    private enum Path {
        static let quote = ["custodial", "quote"]
        static let createOrder = ["custodial", "trades"]
        static let availablePairs = ["custodial", "trades", "pairs"]
        static let fetchOrder = createOrder
        static let updateOrder = createOrder
        static let limits = ["trades", "limits"]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - AvailablePairsClientAPI
    
    var availableOrderPairs: Single<AvailableTradingPairsResponse> {
        let networkRequest = requestBuilder.get(
            path: Path.availablePairs,
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }
    
    // MARK: - CustodialQuoteAPI
    
    func fetchQuoteResponse(with request: OrderQuoteRequest) -> Single<OrderQuoteResponse> {
        let networkRequest = requestBuilder.post(
            path: Path.quote,
            body: try? request.encode(),
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }
    
    // MARK: - OrderCreationClientAPI

    func create(with orderRequest: OrderCreationRequest) -> Single<SwapActivityItemEvent> {
        let networkRequest = requestBuilder.post(
            path: Path.createOrder,
            body: try? orderRequest.encode(),
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }

    // MARK: - OrderUpdateClientAPI

    func updateOrder(with transactionId: String, updateRequest: OrderUpdateRequest) -> Completable {
        let networkRequest = requestBuilder.post(
            path: Path.createOrder + [transactionId],
            body: try? updateRequest.encode(),
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }

    // MARK: - OrderFetchingClientAPI
    
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent> {
        let networkRequest = requestBuilder.get(
            path: Path.fetchOrder + [transactionId],
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }
    
    // MARK: - OrderTransactionLimitsClientAPI
    
    func fetchTransactionLimits(for fiatCurrency: FiatCurrency,
                                networkFee: FiatCurrency,
                                minorValues: Bool) -> Single<TransactionLimits> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            ),
            URLQueryItem(
                name: Parameter.networkFee,
                value: networkFee.code
            ),
            URLQueryItem(
                name: Parameter.minor,
                value: minorValues.description
            )
        ]
        
        let networkRequest = requestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: networkRequest)
    }
}

//
//  SimpleBuyClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public typealias SimpleBuyClientAPI = SimpleBuyEligibilityClientAPI &
                                      SimpleBuySupportedPairsClientAPI &
                                      SimpleBuySuggestedAmountsClientAPI &
                                      SimpleBuyOrderDetailsClientAPI &
                                      SimpleBuyOrderCancellationClientAPI &
                                      SimpleBuyPaymentAccountClientAPI &
                                      SimpleBuyOrderCreationClientAPI &
                                      SimpleBuyCardOrderConfirmationClientAPI &
                                      SimpleBuyQuoteClientAPI &
                                      SimpleBuyPaymentMethodsClientAPI

/// Simple-Buy network client
public final class SimpleBuyClient: SimpleBuyClientAPI {
    
    // MARK: - Types
    
    enum ClientError: Error {
        case unknown
    }
    
    fileprivate enum Parameter {
        static let currency = "currency"
        static let fiatCurrency = "fiatCurrency"
        static let currencyPair = "currencyPair"
        static let action = "action"
        static let amount = "amount"
    }
        
    private enum Path {
        static let paymentMethods = [ "payments", "methods" ]
        static let supportedPairs = [ "simple-buy", "pairs" ]
        static let suggestedAmounts = [ "simple-buy", "amounts" ]
        static let trades = [ "simple-buy", "trades" ]
        static let paymentAccount = [ "payments", "accounts", "simplebuy" ]
        static let quote = [ "simple-buy", "quote" ]
        static let eligible = [ "simple-buy", "eligible" ]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    // MARK: - SimpleBuyEligibilityClientAPI
    
    public func isEligible(for currency: String,
                           token: String) -> Single<SimpleBuyEligibilityResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.fiatCurrency,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.eligible,
            parameters: parameters,
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyOrderCancellationClientAPI
    
    public func cancel(order id: String, token: String) -> Completable {
        let request = requestBuilder.delete(
            path: Path.trades + [id],
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.perform(request: request)
    }
        
    // MARK: - SimpleBuySuggestedAmountsClientAPI
    
    public func suggestedAmounts(for currency: FiatCurrency,
                                 using token: String) -> Single<SimpleBuySuggestedAmountsResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.rawValue
            )
        ]
        let request = requestBuilder.get(
            path: Path.suggestedAmounts,
            parameters: parameters,
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.perform(request: request)
            .flatMap { (rawResponse: [[String: [String]]]) in
                .just(SimpleBuySuggestedAmountsResponse(rawResponse: rawResponse))
            }
    }
    
    // MARK: - SimpleBuySupportedPairsClientAPI
    
    /// Streams the supported Simple-Buy pairs
    public func supportedPairs(with option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairsResponse> {
        let queryParameters: [URLQueryItem]
        switch option {
        case .all:
            queryParameters = []
        case .only(fiatCurrency: let currency):
            queryParameters = [
                URLQueryItem(
                    name: Parameter.currency,
                    value: currency.rawValue
                )
            ]
        }
        let request = requestBuilder.get(
            path: Path.supportedPairs,
            parameters: queryParameters
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyOrderDetailsClientAPI

    public func orderDetails(token: String) -> Single<[SimpleBuyOrderPayload.Response]> {
        let path = Path.trades
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    public func orderDetails(with identifer: String, token: String) -> Single<SimpleBuyOrderPayload.Response> {
        let path = Path.trades + [identifer]
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyPaymentAccountClientAPI
    
    public func paymentAccount(for currency: FiatCurrency, token: String) -> Single<SimpleBuyPaymentAccountResponse> {
        struct Payload: Encodable {
            let currency: String
        }
        
        let payload = Payload(currency: currency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            headers: [HttpHeaderField.authorization: token]
        )!
        return communicator.perform(request: request)
    }

    // MARK: - SimpleBuyOrderCreationClientAPI
    
    public func create(order: SimpleBuyOrderPayload.Request,
                       createPendingOrder: Bool,
                       token: String) -> Single<SimpleBuyOrderPayload.Response> {
        var parameters: [URLQueryItem] = []
        if createPendingOrder {
            parameters.append(
                URLQueryItem(
                    name: Parameter.action,
                    value: SimpleBuyOrderPayload.CreateActionType.pending.rawValue
                )
            )
        }
        
        let path = Path.trades
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.post(
            path: path,
            parameters: parameters,
            body: try? order.encode(),
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyCardOrderConfirmationClientAPI
    
    public func confirmOrder(with identifier: String,
                             partner: SimpleBuyOrderPayload.ConfirmOrder.Partner,
                             token: String) -> Single<SimpleBuyOrderPayload.Response> {
        let payload = SimpleBuyOrderPayload.ConfirmOrder(
            partner: partner,
            action: .confirm
        )
        let path = Path.trades + [identifier]
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyQuoteClientAPI
        
    public func getQuote(for action: SimpleBuyOrder.Action,
                         to cryptoCurrency: CryptoCurrency,
                         amount: FiatValue,
                         token: String) -> Single<SimpleBuyQuoteResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currencyPair,
                value: "\(cryptoCurrency.code)-\(amount.currency.code)"
            ),
            URLQueryItem(
                name: Parameter.action,
                value: action.rawValue
            ),
            URLQueryItem(
                name: Parameter.amount,
                value: amount.string
            )
        ]
        let path = Path.quote
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SimpleBuyPaymentMethodsClientAPI
    
    public func paymentMethods(for currency: String, token: String) -> Single<SimpleBuyPaymentMethodsResponse> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.paymentMethods,
            parameters: queryParameters
        )!
        return communicator.perform(request: request)
    }
}

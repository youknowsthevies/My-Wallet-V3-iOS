//
//  APIClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

typealias SimpleBuyClientAPI = EligibilityClientAPI &
                               SupportedPairsClientAPI &
                               SuggestedAmountsClientAPI &
                               OrderDetailsClientAPI &
                               OrderCancellationClientAPI &
                               PaymentAccountClientAPI &
                               OrderCreationClientAPI &
                               CardOrderConfirmationClientAPI &
                               QuoteClientAPI &
                               PaymentMethodsClientAPI &
                               BeneficiariesClientAPI

/// Simple-Buy network client
final class APIClient: SimpleBuyClientAPI {
    
    // MARK: - Types
        
    fileprivate enum Parameter {
        static let currency = "currency"
        static let fiatCurrency = "fiatCurrency"
        static let currencyPair = "currencyPair"
        static let pendingOnly = "pendingOnly"
        static let action = "action"
        static let amount = "amount"
        static let methods = "methods"
        static let checkEligibility = "checkEligibility"
        static let states = "states"
    }
        
    private enum Path {
        static let paymentMethods = [ "payments", "methods" ]
        static let beneficiaries = [ "payments", "beneficiaries" ]
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
    
    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - BeneficiariesClientAPI
    
    var beneficiaries: Single<[BeneficiaryResponse]> {
        let request = requestBuilder.get(
            path: Path.beneficiaries,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - EligibilityClientAPI
    
    func isEligible(for currency: String,
                    methods: [String]) -> Single<EligibilityResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.fiatCurrency,
                value: currency
            ),
            URLQueryItem(
                name: Parameter.methods,
                value: methods.joined(separator: ",")
            )
        ]
        let request = requestBuilder.get(
            path: Path.eligible,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - OrderCancellationClientAPI
    
    func cancel(order id: String) -> Completable {
        let request = requestBuilder.delete(
            path: Path.trades + [id],
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
        
    // MARK: - SuggestedAmountsClientAPI
    
    func suggestedAmounts(for currency: FiatCurrency) -> Single<SuggestedAmountsResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.rawValue
            )
        ]
        let request = requestBuilder.get(
            path: Path.suggestedAmounts,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - SupportedPairsClientAPI
    
    /// Streams the supported Simple-Buy pairs
    func supportedPairs(with option: SupportedPairsFilterOption) -> Single<SupportedPairsResponse> {
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
    
    // MARK: - OrderDetailsClientAPI

    func orderDetails(pendingOnly: Bool) -> Single<[OrderPayload.Response]> {
        let path = Path.trades
        let states: [OrderDetails.State] = OrderDetails.State.allCases.filter { $0 != .cancelled }
        let parameters = [
            URLQueryItem(
                name: Parameter.pendingOnly,
                value: pendingOnly ? "true" : "false"
            ),
            URLQueryItem(
                name: Parameter.states,
                value: states.map({ $0.rawValue }).joined(separator: ",")
            )
        ]
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    func orderDetails(with identifer: String) -> Single<OrderPayload.Response> {
        let path = Path.trades + [identifer]
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - PaymentAccountClientAPI
    
    func paymentAccount(for currency: FiatCurrency) -> Single<PaymentAccountResponse> {
        struct Payload: Encodable {
            let currency: String
        }
        
        let payload = Payload(currency: currency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }

    // MARK: - OrderCreationClientAPI
    
    func create(order: OrderPayload.Request,
                createPendingOrder: Bool) -> Single<OrderPayload.Response> {
        var parameters: [URLQueryItem] = []
        if createPendingOrder {
            parameters.append(
                URLQueryItem(
                    name: Parameter.action,
                    value: OrderPayload.CreateActionType.pending.rawValue
                )
            )
        }
        
        let path = Path.trades
        let request = requestBuilder.post(
            path: path,
            parameters: parameters,
            body: try? order.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - CardOrderConfirmationClientAPI
    
    func confirmOrder(with identifier: String,
                      partner: OrderPayload.ConfirmOrder.Partner,
                      paymentMethodId: String?) -> Single<OrderPayload.Response> {
        let payload = OrderPayload.ConfirmOrder(
            partner: partner,
            action: .confirm,
            paymentMethodId: paymentMethodId
        )
        let path = Path.trades + [identifier]
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - QuoteClientAPI
        
    func getQuote(for action: Order.Action,
                  to cryptoCurrency: CryptoCurrency,
                  amount: FiatValue) -> Single<QuoteResponse> {
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
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    // MARK: - PaymentMethodsClientAPI
    
    func paymentMethods(for currency: String,
                        checkEligibility: Bool) -> Single<PaymentMethodsResponse> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency
            ),
            URLQueryItem(
                name: Parameter.checkEligibility,
                value: "\(checkEligibility)"
            )
        ]
        let request = requestBuilder.get(
            path: Path.paymentMethods,
            parameters: queryParameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
}

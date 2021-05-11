// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
                                    OrderUpdateClientAPI &
                                    CustodialTransferClientAPI &
                                    BitPayClientAPI

/// TransactionKit network client
final class APIClient: TransactionKitClientAPI {
    
    // MARK: - Types
    
    fileprivate enum Parameter {
        static let minor = "minor"
        static let networkFee = "networkFee"
        static let currency = "currency"
        static let product = "product"
        static let paymentMethod = "paymentMethod"
        static let orderDirection = "orderDirection"
        static let simpleBuy = "SIMPLEBUY"
        static let swap = "SWAP"
        static let `default` = "DEFAULT"
    }
        
    private enum Path {
        static let quote = ["custodial", "quote"]
        static let createOrder = ["custodial", "trades"]
        static let availablePairs = ["custodial", "trades", "pairs"]
        static let fetchOrder = createOrder
        static let limits = ["trades", "limits"]
        static let transfer = [ "payments", "withdrawals" ]
        static let transferFees = [ "payments", "withdrawals", "fees" ]
        static func updateOrder(transactionID: String) -> [String] {
            createOrder + [transactionID]
        }
    }
    
    private enum BitPay {
        static let url: String = "https://bitpay.com/"
        
        enum Paramter {
            static let invoice: String = "i/"
        }
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup
    
    init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - AvailablePairsClientAPI
    
    var availableOrderPairs: Single<AvailableTradingPairsResponse> {
        let request = requestBuilder.get(
            path: Path.availablePairs,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    // MARK: - CustodialQuoteAPI
    
    func fetchQuoteResponse(with request: OrderQuoteRequest) -> Single<OrderQuoteResponse> {
        let request = requestBuilder.post(
            path: Path.quote,
            body: try? request.encode(),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    // MARK: - OrderCreationClientAPI

    func create(with orderRequest: OrderCreationRequest) -> Single<SwapActivityItemEvent> {
        let request = requestBuilder.post(
            path: Path.createOrder,
            body: try? orderRequest.encode(),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    // MARK: - OrderUpdateClientAPI

    func updateOrder(with transactionId: String, updateRequest: OrderUpdateRequest) -> Completable {
        let request = requestBuilder.post(
            path: Path.updateOrder(transactionID: transactionId),
            body: try? updateRequest.encode(),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    // MARK: - OrderFetchingClientAPI
    
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent> {
        let request = requestBuilder.get(
            path: Path.fetchOrder + [transactionId],
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    // MARK: - CustodialTransferClientAPI
    
    func send(transferRequest: CustodialTransferRequest) -> Single<CustodialTransferResponse> {
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let request = requestBuilder.post(
            path: Path.transfer,
            body: try? transferRequest.encode(),
            headers: headers,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    func custodialTransferFees() -> Single<CustodialTransferFeesResponse> {
        let headers = [HttpHeaderField.blockchainOrigin: HttpHeaderValue.simpleBuy]
        let parameters: [URLQueryItem] = [
            URLQueryItem(name: Parameter.product, value: Parameter.simpleBuy),
            URLQueryItem(name: Parameter.paymentMethod, value: Parameter.default)
        ]
        let request = requestBuilder.get(
            path: Path.transferFees,
            parameters: parameters,
            headers: headers,
            authenticated: false
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
    
    // MARK: - BitPayClientAPI
    
    func bitpayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<BitpayPaymentRequest> {
        let payload = ["chain": currency.rawValue]
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPaymentRequest,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceID)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return networkAdapter
            .perform(
                request: request
            )
    }
    
    /// TODO: Probably can be a `Completable`.
    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Completable {
        let transaction = BitPayPayment.Transaction(
            tx: transactionHex,
            weightedSize: transactionSize
        )
        let payload = BitPayPayment(
            chain: currency.rawValue,
            transactions: [transaction]
        )
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPaymentVerification,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceID)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return networkAdapter
            .perform(
                request: request
            )
    }
    
    func postPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        let transaction = BitPayPayment.Transaction(
            tx: transactionHex,
            weightedSize: transactionSize
        )
        let payload = BitPayPayment(
            chain: currency.rawValue,
            transactions: [transaction]
        )
        let headers = [
            HttpHeaderField.xPayProVersion: HttpHeaderValue.xPayProVersion,
            HttpHeaderField.contentType: HttpHeaderValue.bitpayPayment,
            HttpHeaderField.bitpayPartner: HttpHeaderValue.bitpayPartnerName,
            HttpHeaderField.bitpayPartnerVersion: HttpHeaderValue.bitpayPartnerVersion
        ]
        let url = URL(string: BitPay.url + BitPay.Paramter.invoice + invoiceID)!
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: try? JSONEncoder().encode(payload),
            headers: headers
        )
        return networkAdapter
            .perform(
                request: request
            )
    }

    // MARK: - OrderTransactionLimitsClientAPI

    func fetchTransactionLimits(currency: CurrencyType,
                                networkFee: CurrencyType,
                                product: TransactionLimitsProduct) -> Single<TransactionLimits> {
        var parameters: [URLQueryItem] = [
            URLQueryItem(
                name: Parameter.currency,
                value: currency.code
            ),
            URLQueryItem(
                name: Parameter.networkFee,
                value: networkFee.code
            ),
            URLQueryItem(
                name: Parameter.minor,
                value: "true"
            )
        ]
        switch product {
        case .swap(let orderDirection):
            parameters.append(
                URLQueryItem(name: Parameter.product, value: Parameter.swap)
            )
            parameters.append(
                URLQueryItem(name: Parameter.orderDirection, value: orderDirection.rawValue)
            )
        }
        let request = requestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
}

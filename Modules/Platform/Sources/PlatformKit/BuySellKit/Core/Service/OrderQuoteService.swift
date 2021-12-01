// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift

public enum Profile: String, Encodable {
    case simpleBuy = "SIMPLEBUY"
    case simpleTrade = "SIMPLETRADE"
    case swapFromUserKey = "SWAP_FROM_USERKEY"
    case swapInternal = "SWAP_INTERNAL"
    case swapOnChain = "SWAP_ON_CHAIN"
}

public struct QuoteQuery {

    /// The type of quote
    let profile: Profile

    /// The source currency, fiat or crypto
    let sourceCurrency: Currency

    /// The destination curency, fiat or crypto
    let destinationCurrency: Currency

    /// The source amount, fiat or crypto
    let amount: MoneyValue

    /// The payment method if relevant profile is chosen
    let paymentMethod: PaymentMethodPayloadType?

    /// The payment method Id if there is a payment method
    let paymentMethodId: String?

    public init(
        profile: Profile,
        sourceCurrency: Currency,
        destinationCurrency: Currency,
        amount: MoneyValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
    ) {
        self.profile = profile
        self.sourceCurrency = sourceCurrency
        self.destinationCurrency = destinationCurrency
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.paymentMethodId = paymentMethodId
    }
}

/// Used to convert the user input into an actual quote with fee (takes a fiat amount)
public protocol OrderQuoteServiceAPI: AnyObject {

    func getQuote(
        query: QuoteQuery
    ) -> Single<Quote>
}

final class OrderQuoteService: OrderQuoteServiceAPI {

    // MARK: - Properties

    private let client: QuoteClientAPI

    // MARK: - Setup

    init(client: QuoteClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - API

    func getQuote(
        query: QuoteQuery
    ) -> Single<Quote> {
        client.getQuote(
            queryRequest: QuoteQueryRequest(from: query)
        )
        .asSingle()
        .map {
            try Quote(
                sourceCurrency: query.sourceCurrency,
                destinationCurrency: query.destinationCurrency,
                value: query.amount,
                response: $0
            )
        }
    }
}

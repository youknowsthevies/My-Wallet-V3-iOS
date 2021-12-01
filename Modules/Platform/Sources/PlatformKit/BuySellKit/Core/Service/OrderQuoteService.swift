// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift

/// Used to convert the user input into an actual quote with fee (takes a fiat amount)
public protocol OrderQuoteServiceAPI: AnyObject {

    func getQuote(
        for profile: Profile,
        sourceCurrency: Currency,
        destinationCurrency: Currency,
        amount: MoneyValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
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
        for profile: Profile,
        sourceCurrency: Currency,
        destinationCurrency: Currency,
        amount: MoneyValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
    ) -> Single<Quote> {
        client.getQuote(
            for: profile,
            sourceCurrency: sourceCurrency,
            destinationCurrency: destinationCurrency,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentMethodId: paymentMethodId
        )
        .asSingle()
        .map {
            try Quote(
                sourceCurrency: sourceCurrency,
                destinationCurrency: destinationCurrency,
                value: amount,
                response: $0
            )
        }
    }
}

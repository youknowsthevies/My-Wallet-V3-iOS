// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

final class CardOrderCreationService: PendingOrderCreationServiceAPI {

    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI

    init(
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve()
    ) {
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }

    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<PendingConfirmationCheckoutData> {
        let quote = orderQuoteService.getQuote(
            for: .simpleBuy,
            from: candidateOrderDetails.fiatCurrency,
            to: candidateOrderDetails.cryptoCurrency,
            amount: candidateOrderDetails.fiatValue,
            paymentMethod: candidateOrderDetails.paymentMethod?.method.rawType,
            paymentMethodId: candidateOrderDetails.paymentMethodId
        )
        let creation = orderCreationService.create(using: candidateOrderDetails)
        return Single
            .zip(quote, creation)
            .map { quote, checkoutData in
                PendingConfirmationCheckoutData(quote: quote, checkoutData: checkoutData)
            }
    }
}

//
//  CardOrderCheckoutInteractor.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class CardOrderCheckoutInteractor {
    
    private enum InteractionError: Error {
        case orderStateMismatch(is3DSConfirmedCardOrder: Bool, isPending3DSCardOrder: Bool)
        case missingFee
        case missingPaymentMethodId
        case missingPrice

        var localizedDescription: String {
            switch self {
            case .orderStateMismatch(is3DSConfirmedCardOrder: let is3DSConfirmedCardOrder, isPending3DSCardOrder: let isPending3DSCardOrder):
                return "Order state mismatch - got is3DSConfirmedCardOrder: \(is3DSConfirmedCardOrder), isPending3DSCardOrder: \(isPending3DSCardOrder)"
            case .missingFee:
                return "Order fee is missing"
            case .missingPaymentMethodId:
                return "Order payment method ID is missing"
            case .missingPrice:
                return "Order price is missing"
            }
        }
    }
    
    private let cardListService: CardListServiceAPI
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI
    
    public init(cardListService: CardListServiceAPI,
                orderQuoteService: OrderQuoteServiceAPI,
                orderCreationService: OrderCreationServiceAPI) {
        self.cardListService = cardListService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    /// Fetch the quote and append it to the result along with the checkout data.
    func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        guard let paymentMethodId = checkoutData.order.paymentMethodId else {
            fatalError(InteractionError.missingPaymentMethodId.localizedDescription)
        }
        
       return orderQuoteService
            .getQuote(
               for: .buy,
               cryptoCurrency: checkoutData.order.cryptoValue.currencyType,
               fiatValue: checkoutData.order.fiatValue
            )
            .flatMap(weak: self) { (self, quote) in
                self.cardListService
                    .card(by: paymentMethodId)
                    .map { card in
                        let interactionData = CheckoutInteractionData(
                            time: quote.time,
                            fee: checkoutData.order.fee ?? quote.fee,
                            amount: quote.estimatedAmount,
                            exchangeRate: quote.rate,
                            card: card,
                            orderId: checkoutData.order.identifier
                        )
                        return (interactionData, checkoutData)
                    }
            }
    }
    
    func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        /// 3DS was confirmed on this order - just fetch the details
        guard order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder else {
            fatalError(
                InteractionError.orderStateMismatch(
                    is3DSConfirmedCardOrder: order.is3DSConfirmedCardOrder,
                    isPending3DSCardOrder: order.isPending3DSCardOrder
                ).localizedDescription
            )
        }
        
        guard let paymentMethodId = order.paymentMethodId else {
            fatalError(InteractionError.missingPaymentMethodId.localizedDescription)
        }
        
        guard let fee = order.fee else {
            fatalError(InteractionError.missingFee.localizedDescription)
        }
        
        guard let price = order.price else {
            fatalError(InteractionError.missingPrice.localizedDescription)
        }

        return cardListService
            .card(by: paymentMethodId)
            .map { card in
                CheckoutInteractionData(
                    time: order.creationDate,
                    fee: fee,
                    amount: order.cryptoValue,
                    exchangeRate: price,
                    card: card,
                    orderId: order.identifier
                )
            }
    }
}

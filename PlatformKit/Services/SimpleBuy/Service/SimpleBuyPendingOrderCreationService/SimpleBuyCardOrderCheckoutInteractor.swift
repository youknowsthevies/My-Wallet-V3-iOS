//
//  SimpleBuyCardOrderCheckoutInteractor.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyCardOrderCheckoutInteractor {
    
    private enum InteractionError: Error {
        case missingOrder
        case missingPaymentMethodId
        case orderStateMismatch
        case missingInternalOrderData
    }
    
    private let cardListService: CardListServiceAPI
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI
    
    public init(cardListService: CardListServiceAPI,
                orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
                orderCreationService: SimpleBuyOrderCreationServiceAPI) {
        self.cardListService = cardListService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    /// Fetch the quote and append it to the result along with the checkout data.
    public func prepare(using checkoutData: SimpleBuyCheckoutData) -> Single<(interactionData: SimpleBuyCheckoutInteractionData, checkoutData: SimpleBuyCheckoutData)> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        guard let paymentMethodId = order.paymentMethodId else {
            return .error(InteractionError.missingPaymentMethodId)
        }
        
        return orderQuoteService
            .getQuote(
                for: .buy,
                using: checkoutData
            )
            .flatMap(weak: self) { (self, quote) in
                self.cardListService
                    .card(by: paymentMethodId)
                    .map { card in
                        let interactionData = SimpleBuyCheckoutInteractionData(
                            time: quote.time,
                            fee: order.fee ?? quote.fee,
                            amount: quote.estimatedAmount,
                            exchangeRate: quote.rate,
                            card: card,
                            orderId: order.identifier
                        )
                        return (interactionData, checkoutData)
                    }
            }
    }
    
    public func prepare(using order: SimpleBuyOrderDetails) -> Single<SimpleBuyCheckoutInteractionData> {
        /// 3DS was confirmed on this order - just fetch the details
        guard order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder else {
            return .error(InteractionError.orderStateMismatch)
        }
        
        guard let paymentMethodId = order.paymentMethodId else {
            return .error(InteractionError.missingPaymentMethodId)
        }
        
        guard let fee = order.fee else {
            return .error(InteractionError.missingInternalOrderData )
        }
        guard let price = order.price else {
            return .error(InteractionError.missingInternalOrderData )
        }

        return cardListService
            .card(by: paymentMethodId)
            .map { card in
                SimpleBuyCheckoutInteractionData(
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

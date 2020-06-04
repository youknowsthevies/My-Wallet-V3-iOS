//
//  SimpleBuyBankOrderCheckoutInteractor.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyBankOrderCheckoutInteractor {
    
    private enum InteractionError: Error {
        case missingOrder
        case missingOrderInternalData
        case orderIsNotPendingDepositBankTransfer
    }
    
    private let paymentAccountService: SimpleBuyPaymentAccountServiceAPI
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI

    public init(paymentAccountService: SimpleBuyPaymentAccountServiceAPI,
                orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
                orderCreationService: SimpleBuyOrderCreationServiceAPI) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    /// 1. Fetch the payment account matching the order currency and append it to the checkout data
    /// 2. Fetch the quote and append it to the result.
    /// The order must be created beforehand and present in the checkout data.
    public func prepare(using checkoutData: SimpleBuyCheckoutData) -> Single<(interactionData: SimpleBuyCheckoutInteractionData, checkoutData: SimpleBuyCheckoutData)> {
        guard let order = checkoutData.detailType.order else {
            return .error(InteractionError.missingOrder)
        }
        return paymentAccountService
            .paymentAccount(for: checkoutData.fiatValue.currency)
            .map { account -> SimpleBuyCheckoutData in
                checkoutData.checkoutData(byAppending: account)
            }
            .flatMap(weak: self) { (self, checkoutData) in
                self.orderQuoteService
                    .getQuote(
                        for: .buy,
                        using: checkoutData
                    )
                    .map { quote -> (quote: SimpleBuyQuote, checkoutData: SimpleBuyCheckoutData) in
                        (quote, checkoutData)
                    }
            }
            .map { payload in
                let interactionData = SimpleBuyCheckoutInteractionData(
                    time: payload.quote.time,
                    fee: order.fee ?? payload.quote.fee,
                    amount: payload.quote.estimatedAmount,
                    exchangeRate: payload.quote.rate,
                    card: nil,
                    orderId: order.identifier
                )
                return (interactionData, payload.checkoutData)
            }
    }
    
    public func prepare(using order: SimpleBuyOrderDetails) -> Single<SimpleBuyCheckoutInteractionData> {
        guard order.isPendingDepositBankWire else {
            return .error(InteractionError.orderIsNotPendingDepositBankTransfer)
        }
        
        // order was confirmed - just fetch the details
        guard let fee = order.fee else {
            return .error(InteractionError.missingOrderInternalData)
        }

        return .just(
            SimpleBuyCheckoutInteractionData(
                time: order.creationDate,
                fee: fee,
                amount: order.cryptoValue,
                exchangeRate: nil,
                card: nil,
                orderId: order.identifier
            )
        )
    }
}

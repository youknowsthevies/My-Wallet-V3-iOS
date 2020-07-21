//
//  FundsAndBankOrderCheckoutInteractor.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class FundsAndBankOrderCheckoutInteractor {
    
    private enum InteractionError: Error {
        case missingOrderFee
        case orderIsNotPendingDepositBankTransfer
        
        var localizedDescription: String {
            switch self {
            case .missingOrderFee:
                return "Order fee is missing"
            case .orderIsNotPendingDepositBankTransfer:
                return "Order is not a pending deposit bank transfer"
            }
        }
    }
        
    private let paymentAccountService: PaymentAccountServiceAPI
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI
    
    public init(paymentAccountService: PaymentAccountServiceAPI,
                orderQuoteService: OrderQuoteServiceAPI,
                orderCreationService: OrderCreationServiceAPI) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }
    
    /// 1. Fetch the payment account matching the order currency and append it to the checkout data
    /// 2. Fetch the quote and append it to the result.
    /// The order must be created beforehand and present in the checkout data.
    func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        let quote = orderQuoteService
            .getQuote(
               for: .buy,
               cryptoCurrency: checkoutData.order.cryptoValue.currencyType,
               fiatValue: checkoutData.order.fiatValue
            )

        let finalCheckoutData: Single<CheckoutData>
        if checkoutData.order.paymentMethod.isBankTransfer {
            finalCheckoutData = paymentAccountService
                .paymentAccount(for: checkoutData.order.fiatValue.currencyType)
                .map { checkoutData.checkoutData(byAppending: $0) }
        } else {
            finalCheckoutData = Single.just(checkoutData)
        }
        
        return Single
            .zip(
                quote,
                finalCheckoutData
            )
            .map { (payload: (quote: Quote, checkoutData: CheckoutData)) in
                let interactionData = CheckoutInteractionData(
                    time: payload.quote.time,
                    fee: payload.checkoutData.order.fee ?? payload.quote.fee,
                    amount: payload.quote.estimatedAmount,
                    exchangeRate: payload.quote.rate,
                    card: nil,
                    orderId: payload.checkoutData.order.identifier,
                    paymentMethod: checkoutData.order.paymentMethod
                )
                return (interactionData, payload.checkoutData)
            }
    }
    
    func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        guard order.paymentMethod.isFunds || order.isPendingDepositBankWire else {
            fatalError(InteractionError.orderIsNotPendingDepositBankTransfer.localizedDescription)
        }
        
        // order was confirmed - just fetch the details
        guard let fee = order.fee else {
            fatalError(InteractionError.missingOrderFee.localizedDescription)
        }

        return .just(
            CheckoutInteractionData(
                time: order.creationDate,
                fee: fee,
                amount: order.cryptoValue,
                exchangeRate: nil,
                card: nil,
                orderId: order.identifier,
                paymentMethod: order.paymentMethod
            )
        )
    }
}

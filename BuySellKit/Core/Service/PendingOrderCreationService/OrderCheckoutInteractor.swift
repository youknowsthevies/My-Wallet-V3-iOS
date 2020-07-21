//
//  OrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 02/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class OrderCheckoutInteractor {
    
    // MARK: - Properties
    
    private let fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor
    private let cardInteractor: CardOrderCheckoutInteractor

    // MARK: - Setup
    
    public init(fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor,
                cardInteractor: CardOrderCheckoutInteractor) {
        self.fundsAndBankInteractor = fundsAndBankInteractor
        self.cardInteractor = cardInteractor
    }
    
    public func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        switch checkoutData.order.paymentMethod {
        case .card:
            return cardInteractor.prepare(using: checkoutData)
        case .bankTransfer, .funds:
            return fundsAndBankInteractor.prepare(using: checkoutData)
        }
    }
    
    public func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        switch order.paymentMethod {
        case .card:
            return cardInteractor.prepare(using: order)
        case .bankTransfer, .funds:
            return fundsAndBankInteractor.prepare(using: order)
        }
    }
}

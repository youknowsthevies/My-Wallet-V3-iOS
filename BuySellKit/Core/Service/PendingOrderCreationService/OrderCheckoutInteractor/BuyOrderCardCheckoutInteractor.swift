//
//  BuyOrderCardCheckoutInteractor.swift
//  BuySellKit
//
//  Created by Alex McGregor on 9/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class BuyOrderCardCheckoutInteractor: OrderCheckoutInteracting {
    
    // MARK: - Properties
    
    private let cardInteractor: CardOrderCheckoutInteractor

    // MARK: - Setup
    
    public init(cardInteractor: CardOrderCheckoutInteractor) {
        self.cardInteractor = cardInteractor
    }
    
    public func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        cardInteractor.prepare(using: checkoutData)
    }
    
    public func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        cardInteractor.prepare(using: order)
    }
}

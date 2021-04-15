//
//  SellOrderCheckoutInteractor.swift
//  BuySellKit
//
//  Created by Alex McGregor on 9/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SellOrderCheckoutInteractor: OrderCheckoutInteracting {
    
    // MARK: - Properties
    
    private let fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor

    // MARK: - Setup
    
    public init(fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor) {
        self.fundsAndBankInteractor = fundsAndBankInteractor
    }
    
    public func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        fundsAndBankInteractor.prepare(using: checkoutData, action: .sell)
    }
    
    public func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        fundsAndBankInteractor.prepare(using: order)
    }
}

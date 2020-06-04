//
//  SimpleBuyOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 02/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyOrderCheckoutInteractor {
    
    // MARK: - Properties
    
    private let bankInteractor: SimpleBuyBankOrderCheckoutInteractor
    private let cardInteractor: SimpleBuyCardOrderCheckoutInteractor

    // MARK: - Setup
    
    public init(bankInteractor: SimpleBuyBankOrderCheckoutInteractor,
                cardInteractor: SimpleBuyCardOrderCheckoutInteractor) {
        self.bankInteractor = bankInteractor
        self.cardInteractor = cardInteractor
    }
    
    public func prepare(using checkoutData: SimpleBuyCheckoutData) -> Single<(interactionData: SimpleBuyCheckoutInteractionData, checkoutData: SimpleBuyCheckoutData)> {
        switch checkoutData.detailType.paymentMethod {
        case .card:
            return cardInteractor.prepare(using: checkoutData)
        case .bankTransfer:
            return bankInteractor.prepare(using: checkoutData)
        }
    }
    
    public func prepare(using order: SimpleBuyOrderDetails) -> Single<SimpleBuyCheckoutInteractionData> {
        switch order.paymentMethod {
        case .card:
            return cardInteractor.prepare(using: order)
        case .bankTransfer:
            return bankInteractor.prepare(using: order)
        }
    }
}

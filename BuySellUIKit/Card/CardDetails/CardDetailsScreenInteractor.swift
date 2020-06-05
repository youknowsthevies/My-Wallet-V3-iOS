//
//  CardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import BuySellKit

final class CardDetailsScreenInteractor {

    // MARK: - Properties
    
    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsService.supportedCardTypes
    }
    
    private let paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    
    // MARK: - Setup
    
    init(paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI,
         cardListService: CardListServiceAPI) {
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
    }
    
    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool> {
        cardListService.doesCardExist(number: number, expiryMonth: expiryMonth, expiryYear: expiryYear)
    }
}

//
//  CardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

final class CardDetailsScreenInteractor: Interactor {

    // MARK: - Properties
    
    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsService.supportedCardTypes
    }
    
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    private let routingInteractor: CardRouterInteractor
    
    // MARK: - Setup
    
    init(routingInteractor: CardRouterInteractor,
         paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
         cardListService: CardListServiceAPI = resolve()) {
        self.routingInteractor = routingInteractor
        self.paymentMethodsService = paymentMethodsService
        self.cardListService = cardListService
    }
    
    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> Single<Bool> {
        cardListService.doesCardExist(number: number, expiryMonth: expiryMonth, expiryYear: expiryYear)
    }
    
    func addBillingAddress(to cardData: CardData) {
        routingInteractor.addBillingAddress(to: cardData)
    }
    
    func cancel() {
        routingInteractor.previousRelay.accept(())
    }
}

//
//  AddCardInteractor.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import BuySellKit

final class AddCardInteractor: AddSpecificPaymentMethodInteractorAPI {
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    
    var isAbleToAddNew: Observable<Bool> {
        activeCards
            .map { $0.count < CardData.maxCardCount }
            .share(replay: 1)
    }
    
    private var activeCards: Observable<[CardData]> {
        paymentMethodTypesService.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }
        
    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI) {
        self.paymentMethodTypesService = paymentMethodTypesService
    }
}

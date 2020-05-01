//
//  CardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 29/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class CardDetailsScreenInteractor {

    // MARK: - Properties
    
    var supportedCardTypes: Single<Set<CardType>> {
        paymentMethodsService.supportedCardTypes
    }
    
    private let paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI
    
    // MARK: - Setup
    
    init(paymentMethodsService: SimpleBuyPaymentMethodsServiceAPI) {
        self.paymentMethodsService = paymentMethodsService
    }
}

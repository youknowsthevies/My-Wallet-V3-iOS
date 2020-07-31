//
//  AddBankInteractor.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxSwift

final class AddBankInteractor: AddSpecificPaymentMethodInteractorAPI {
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let fiatCurrency: FiatCurrency
    
    var isAbleToAddNew: Observable<Bool> {
        let fiatCurrency = self.fiatCurrency
        return paymentMethodTypesService.availableCurrenciesForBankLinkage
            .map { $0.contains(fiatCurrency) }
            .catchErrorJustReturn(false)
            .share(replay: 1)
    }
    
    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         fiatCurrency: FiatCurrency) {
        self.fiatCurrency = fiatCurrency
        self.paymentMethodTypesService = paymentMethodTypesService
    }
}

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
    
    private let beneficiariesService: BeneficiariesServiceAPI
    private let fiatCurrency: FiatCurrency
    
    var isAbleToAddNew: Observable<Bool> {
        let fiatCurrency = self.fiatCurrency
        return beneficiariesService.availableCurrenciesForBankLinkage
            .map { currencies -> Bool in
                currencies.contains(fiatCurrency)
            }
            .catchErrorJustReturn(false)
            .share(replay: 1)
    }
    
    init(beneficiariesService: BeneficiariesServiceAPI,
         fiatCurrency: FiatCurrency) {
        self.fiatCurrency = fiatCurrency
        self.beneficiariesService = beneficiariesService
    }
}

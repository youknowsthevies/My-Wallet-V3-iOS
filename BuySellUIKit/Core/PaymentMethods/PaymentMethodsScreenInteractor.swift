//
//  PaymentMethodsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxSwift
import PlatformUIKit

final class PaymentMethodsScreenInteractor {
    
    // MARK: - Properties
    
    /// Streams the available payment methods
    var methods: Single<[PaymentMethodType]> {
        let methodTypes = paymentMethodTypesService.methodTypes
            .take(1)
            .asSingle()
        
        return Single
            .zip(
                methodTypes,
                fiatCurrencyService.fiatCurrency
            )
            .map { payload in
                let (methods, fiatCurrency) = payload
                return methods
                    .filter { type in
                        switch type {
                        case .card(let data):
                            return data.state == .active
                        case .suggested(let method):
                            switch method.type {
                            case .bankTransfer:
                                return false
                            case .card, .funds(fiatCurrency.currency):
                                return true
                            case .funds:
                                return false
                            }
                        case .account(let pairs):
                            return pairs.base.currencyType == fiatCurrency.currency
                        }
                    }
            }
    }
    
    // MARK: - Injected
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    
    // MARK: - Setup
    
    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         fiatCurrencyService: FiatCurrencyServiceAPI) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.fiatCurrencyService = fiatCurrencyService
    }
    
    func select(method: PaymentMethodType) {
        paymentMethodTypesService.preferredPaymentMethodTypeRelay.accept(method)
    }
    
    func custodialFiatBalanceViewInteractor(by balance: MoneyValueBalancePairs) -> FiatCustodialBalanceViewInteractor {
        FiatCustodialBalanceViewInteractor(balance: balance)
    }
}

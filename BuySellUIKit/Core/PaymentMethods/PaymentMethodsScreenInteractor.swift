//
//  PaymentMethodsScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
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
                return methods.filterValidForBuy(currentWalletCurrency: fiatCurrency)
            }
    }
    
    var isUserEligibleForFunds: Single<Bool> {
        kycTiers.tiers.map(\.isTier2Approved)
    }
    
    // MARK: - Injected
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiers: KYCTiersServiceAPI
    
    // MARK: - Setup
    
    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         kycTiers: KYCTiersServiceAPI = resolve()) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiers = kycTiers
    }
    
    func select(method: PaymentMethodType) {
        paymentMethodTypesService.preferredPaymentMethodTypeRelay.accept(method)
    }
    
    func custodialFiatBalanceViewInteractor(by balance: MoneyValueBalancePairs) -> FiatCustodialBalanceViewInteractor {
        FiatCustodialBalanceViewInteractor(balance: balance)
    }
}

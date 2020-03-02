//
//  CheckoutScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class CheckoutScreenInteractor {
    
    // MARK: - Properties
    
    private(set) var checkoutData: SimpleBuyCheckoutData
    
    // MARK: - Services
    
    private let paymentAccountService: SimpleBuyPaymentAccountServiceAPI
    private let orderQuoteService: SimpleBuyOrderQuoteServiceAPI
    private let orderCreationService: SimpleBuyOrderCreationServiceAPI
    
    // MARK: - Setup
    
    init(paymentAccountService: SimpleBuyPaymentAccountServiceAPI,
         orderQuoteService: SimpleBuyOrderQuoteServiceAPI,
         orderCreationService: SimpleBuyOrderCreationServiceAPI,
         checkoutData: SimpleBuyCheckoutData) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
        self.checkoutData = checkoutData
    }
    
    func setup() -> Single<SimpleBuyQuote> {
        return paymentAccountService
            .paymentAccount(for: checkoutData.fiatValue.currency)
            .flatMap(weak: self) { (self, account) -> Single<SimpleBuyCheckoutData> in
                self.set(account: account)
            }
            .flatMap(weak: self) { (self, checkoutData) -> Single<SimpleBuyQuote> in
                self.orderQuoteService.getQuote(
                    for: .buy,
                    using: checkoutData
                )
            }
    }
    
    /// Creates the order itself
    func buy() -> Observable<Void> {
        return orderCreationService.buy(using: checkoutData)
            .andThen(.just(()))
    }
    
    private func set(account: SimpleBuyPaymentAccount) -> Single<SimpleBuyCheckoutData> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.checkoutData = self.checkoutData.checkoutData(byAppending: account)
                observer(.success(self.checkoutData))
                return Disposables.create()
            }
    }
}

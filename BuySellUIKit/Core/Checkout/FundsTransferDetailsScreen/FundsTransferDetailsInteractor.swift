//
//  FundsTransferDetailsInteractor.swift
//  BuySellUIKit
//
//  Created by Daniel on 23/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import BuySellKit

typealias FundsTransferDetailsInteractionState = ValueCalculationState<PaymentAccount>

protocol FundsTransferDetailsInteractorAPI: AnyObject {
    var state: Observable<FundsTransferDetailsInteractionState> { get }
}

final class InteractiveFundsTransferDetailsInteractor: FundsTransferDetailsInteractorAPI {
                        
    // MARK: - Properties
    
    var state: Observable<FundsTransferDetailsInteractionState> {
        paymentAccountRelay.compactMap { $0 }
    }
    
    private let paymentAccountService: PaymentAccountServiceAPI
    private let fiatCurrency: FiatCurrency
    private let paymentAccountRelay = BehaviorRelay<FundsTransferDetailsInteractionState>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(paymentAccountService: PaymentAccountServiceAPI, fiatCurrency: FiatCurrency) {
        self.paymentAccountService = paymentAccountService
        self.fiatCurrency = fiatCurrency
        
        paymentAccountService.paymentAccount(for: fiatCurrency)
            .asObservable()
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bindAndCatch(to: paymentAccountRelay)
            .disposed(by: disposeBag)
    }
}

final class StaleFundsTransferDetailsInteractor: FundsTransferDetailsInteractorAPI {
                
    // MARK: - Exposed Properties
    
    var state: Observable<FundsTransferDetailsInteractionState> {
        .just(.value(checkoutData.paymentAccount))
    }

    private let checkoutData: CheckoutData
            
    // MARK: - Setup
    
    init(checkoutData: CheckoutData) {
        self.checkoutData = checkoutData
    }
}

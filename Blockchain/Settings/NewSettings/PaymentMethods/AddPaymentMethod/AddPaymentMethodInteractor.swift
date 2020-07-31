//
//  AddCardBadgeInteractor.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class AddPaymentMethodInteractor {

    enum PaymentMethod {
        case card
        case bank(FiatCurrency)
        
        var appFeature: AppFeature {
            switch self {
            case .card:
                return .simpleBuyCardsEnabled
            case .bank:
                return .simpleBuyFundsEnabled
            }
        }
        
        var fiatCurrency: FiatCurrency? {
            guard case .bank(let currency) = self else { return nil }
            return currency
        }
    }
    
    /// Do all the checks and streams `true` if the user is able to add a new bank / card / whatever payment method
    var isEnabledForUser: Observable<Bool> {
        Observable
            .combineLatest(isAbleToAddNew, isKYCVerified, isFeatureEnabled)
            .map { $0.0 && $0.1 && $0.2 }
            .share(replay: 1)
    }
    
    var isAbleToAddNew: Observable<Bool> {
        addNewInteractor.isAbleToAddNew
            .catchErrorJustReturn(false)
            .share(replay: 1)
    }
    
    var isKYCVerified: Observable<Bool> {
        tiersLimitsProvider
            .tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
            .share(replay: 1)
    }
    
    var isFeatureEnabled: Observable<Bool> {
        featureFetcher
            .fetchBool(for: paymentMethod.appFeature)
            .catchErrorJustReturn(false)
            .asObservable()
    }
    
    let paymentMethod: PaymentMethod
    private let addNewInteractor: AddSpecificPaymentMethodInteractorAPI
    private let tiersLimitsProvider: TierLimitsProviding
    private let featureFetcher: FeatureFetching
    
    init(paymentMethod: PaymentMethod,
         addNewInteractor: AddSpecificPaymentMethodInteractorAPI,
         tiersLimitsProvider: TierLimitsProviding,
         featureFetcher: FeatureFetching) {
        self.paymentMethod = paymentMethod
        self.featureFetcher = featureFetcher
        self.addNewInteractor = addNewInteractor
        self.tiersLimitsProvider = tiersLimitsProvider
    }
}

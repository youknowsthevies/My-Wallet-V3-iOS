//
//  AddCardBadgeInteractor.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
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
    let isEnabledForUser: Observable<Bool>
    
    let isAbleToAddNew: Observable<Bool>
    
    let isKYCVerified: Observable<Bool>
    
    let isFeatureEnabled: Observable<Bool>
    
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

        isAbleToAddNew = addNewInteractor.isAbleToAddNew
            .catchErrorJustReturn(false)
            .share(replay: 1)

        isKYCVerified = tiersLimitsProvider.tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
            .share(replay: 1)

        isFeatureEnabled = featureFetcher.fetchBool(for: paymentMethod.appFeature)
            .catchErrorJustReturn(false)
            .asObservable()

        isEnabledForUser = Observable.combineLatest(isAbleToAddNew, isKYCVerified, isFeatureEnabled)
            .map { $0.0 && $0.1 && $0.2 }
            .share(replay: 1)

    }
}

//
//  AddCardBadgePresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class AddCardBadgePresenter: BadgeImageAssetPresenting {
    
    typealias BadgeImageState = LoadingState<BadgeImageViewModel>
    
    var state: Observable<BadgeImageState> {
        stateRelay.asObservable()
    }
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let tiersLimitsProviding: TierLimitsProviding
    private let featureFetcher: FeatureFetching
    
    private let stateRelay = BehaviorRelay<BadgeImageState>(value: .loading)
    private let disposeBag = DisposeBag()
    private var isKYCVerified: Observable<Bool> {
        tiersLimitsProviding
            .tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
    }
    
    private var activeCards: Observable<[CardData]> {
        paymentMethodTypesService.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }
    
    init(paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureFetcher: FeatureFetching) {
        self.tiersLimitsProviding = tierLimitsProviding
        self.paymentMethodTypesService = paymentMethodTypesService
        self.featureFetcher = featureFetcher
        setup()
    }
    
    private func setup() {
        let featureEnabled = featureFetcher
            .fetchBool(for: .simpleBuyCardsEnabled)
            .asObservable()
        
        Observable
            .combineLatest(activeCards, isKYCVerified, featureEnabled)
            .map { $0.0.count < CardData.maxCardCount && $0.1 && $0.2 }
            .map { $0 ? .card : .info }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

fileprivate extension BadgeImageViewModel {
    static let card: BadgeImageViewModel = .primary(
        with: "Icon-Creditcard",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )
    
    static let info: BadgeImageViewModel = .default(
        with: "Icon-Info",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )
}

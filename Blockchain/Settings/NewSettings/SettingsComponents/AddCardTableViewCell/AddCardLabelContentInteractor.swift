//
//  AddCardLabelContentInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class AddCardLabelContentInteractor: LabelContentInteracting {
    
    // MARK: - Types

    typealias AccessibilityID = Accessibility.Identifier.Settings
    typealias LocalizationString = LocalizationConstants.Settings.Cards
    typealias InteractionState = LabelContent.State.Interaction
    typealias Descriptors = LabelContent.Value.Presentation.Content.Descriptors

    // MARK: - Properties
    
    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
    
    let descriptorRelay = BehaviorRelay<Descriptors>(value: .settings)
    var descriptorObservable: Observable<Descriptors> {
        descriptorRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let disposeBag = DisposeBag()
    private let tierLimitsProviding: TierLimitsProviding
    private let featureFetcher: FeatureFetching
    private let paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI
    private var isKYCVerified: Observable<Bool> {
        tierLimitsProviding
            .tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
    }

    private var activeCards: Observable<[CardData]> {
        paymentMethodTypesService.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }
    
    // MARK: - Setup
    
    init(paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureFetcher: FeatureFetching) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProviding = tierLimitsProviding
        self.featureFetcher = featureFetcher
        setup()
    }
    
    private func setup() {
        
        let featureEnabled = featureFetcher
            .fetchBool(for: .simpleBuyCardsEnabled)
            .asObservable()
        let data = Observable
            .combineLatest(activeCards, isKYCVerified, featureEnabled)
            .map {
                (
                    isCardCountBelowLimit: $0.0.count < CardData.maxCardCount,
                    isKYCVerified: $0.1,
                    isFeatureEnabled: $0.2
                )
            }
            .share(replay: 1)
        
        data
            .map { $0.isCardCountBelowLimit && $0.isKYCVerified && $0.isFeatureEnabled }
            .map { $0 ? .settings : .disclaimer(accessibilityId: AccessibilityID.AddCardCell.disclaimer) }
            .bindAndCatch(to: descriptorRelay)
            .disposed(by: disposeBag)
            
        data
            .map { data in
                guard data.isFeatureEnabled else { return LocalizationString.disabled }
                guard data.isKYCVerified else { return LocalizationString.unverified }
                guard data.isCardCountBelowLimit else { return LocalizationString.maximum }
                return LocalizationString.addACard
            }
            .map { .loaded(next: .init(text: $0)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

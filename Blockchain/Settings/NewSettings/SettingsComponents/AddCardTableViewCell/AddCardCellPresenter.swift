//
//  AddCardCellPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class AddCardCellPresenter: AsyncPresenting {
    
    // MARK: - Types
    
    private typealias LocalizationIDs = LocalizationConstants.Settings.Cards
    
    // MARK: - Public
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    var action: SettingsScreenAction {
        actionTypeRelay.value
    }
    
    var addIconImageVisibility: Driver<Visibility> {
        imageVisibilityRelay.asDriver()
    }
    
    let descriptionLabelContent: LabelContent = .init(
        text: LocalizationIDs.addACard,
        font: .main(.medium, 16.0),
        color: .textFieldText,
        alignment: .left,
        accessibility: .none
    )
    
    let badgeImagePresenter: BadgeImageAssetPresenting
    let labelContentPresenter: AddCardLabelContentPresenter
    
    // MARK: - Private Properties
    
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let tierLimitsProviding: TierLimitsProviding
    private let featureFetcher: FeatureFetching
    
    private let imageVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let actionTypeRelay = BehaviorRelay<SettingsScreenAction>(value: .none)
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
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
    
    init(paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureFetcher: FeatureFetching) {
        
        self.featureFetcher = featureFetcher
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProviding = tierLimitsProviding
        
        labelContentPresenter = AddCardLabelContentPresenter(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding,
            featureFeatcher: featureFetcher
        )
        badgeImagePresenter = AddCardBadgePresenter(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding,
            featureFetcher: featureFetcher
        )
        setup()
    }
    
    private func setup() {
        
        let featureEnabled = featureFetcher
            .fetchBool(for: .simpleBuyCardsEnabled)
            .asObservable()
        
        let isAbleToAddCard = Observable
            .combineLatest(activeCards, isKYCVerified, featureEnabled)
            .map { $0.0.count < CardData.maxCardCount && $0.1 && $0.2 }
            .share(replay: 1)
        
        isAbleToAddCard
            .map { $0 ? .visible : .hidden }
            .bindAndCatch(to: imageVisibilityRelay)
            .disposed(by: disposeBag)
        
        isAbleToAddCard
            .map { $0 ? .showAddCardScreen : .none }
            .bindAndCatch(to: actionTypeRelay)
            .disposed(by: disposeBag)
        
        badgeImagePresenter.state
            .map { $0.isLoading }
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

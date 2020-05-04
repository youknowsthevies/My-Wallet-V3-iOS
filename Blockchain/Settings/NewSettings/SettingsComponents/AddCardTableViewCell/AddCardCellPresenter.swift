//
//  AddCardCellPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa

final class AddCardCellPresenter: SettingsAsyncPresenting {
    
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
        font: .mainMedium(16.0),
        color: .textFieldText,
        alignment: .left,
        accessibility: .none
    )

    let badgeImageViewModel: BadgeImageViewModel = .primary(
        with: "icon-card",
        cornerRadius: .value(14),
        accessibilityIdSuffix: ""
    )
    
    let badgeImagePresenter: BadgeImageAssetPresenting
    let labelContentPresenter: AddCardLabelContentPresenter
    
    // MARK: - Private Properties
    
    private let paymentMethodTypesService: SimpleBuyPaymentMethodTypesService
    private let tierLimitsProviding: TierLimitsProviding
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
    
    init(paymentMethodTypesService: SimpleBuyPaymentMethodTypesService, tierLimitsProviding: TierLimitsProviding) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProviding = tierLimitsProviding
        
        labelContentPresenter = AddCardLabelContentPresenter(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding
        )
        badgeImagePresenter = AddCardBadgePresenter(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding
        )
        setup()
    }
    
    private func setup() {
        
        let isAbleToAddCard = Observable
            .combineLatest(activeCards, isKYCVerified)
            .map { $0.0.count < CardData.maxCardCount && $0.1 }
            .share(replay: 1)
        
        isAbleToAddCard
            .map { $0 ? .visible : .hidden }
            .bind(to: imageVisibilityRelay)
            .disposed(by: disposeBag)
        
        isAbleToAddCard
            .map { $0 ? .showAddCardScreen : .none }
            .bind(to: actionTypeRelay)
            .disposed(by: disposeBag)
        
        badgeImagePresenter.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

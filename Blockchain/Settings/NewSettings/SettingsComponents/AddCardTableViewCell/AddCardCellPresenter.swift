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
    
    // MARK: - Localization
    
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
    
    private let cardListService: CardListServiceAPI
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
    private var cards: Observable<[CardData]> {
        cardListService.cards.catchErrorJustReturn([])
    }
    
    init(service: CardListServiceAPI, tierLimitsProviding: TierLimitsProviding) {
        self.cardListService = service
        self.tierLimitsProviding = tierLimitsProviding
        
        labelContentPresenter = AddCardLabelContentPresenter(
            service: service,
            tierLimitsProviding: tierLimitsProviding
        )
        badgeImagePresenter = AddCardBadgePresenter(
            service: service,
            tierLimitsProviding: tierLimitsProviding
        )
        setup()
    }
    
    private func setup() {
        Observable.combineLatest(cards, isKYCVerified)
            .map { $0.0.count < 3 && $0.1 }
            .map { $0 ? .visible : .hidden }
            .bind(to: imageVisibilityRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(cards, isKYCVerified)
            .map { $0.0.count < 3 && $0.1 }
            .map { $0 ? .showAddCardScreen : .none }
            .bind(to: actionTypeRelay)
            .disposed(by: disposeBag)
        
        badgeImagePresenter.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
